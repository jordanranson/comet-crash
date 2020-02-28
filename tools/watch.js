const fs = require('fs')
const chalk = require('chalk')
const argv = require('minimist')(process.argv.slice(2))

const sourcePath = argv.src
const destPath = argv.dest
const fileName = argv.name

function readFile (path) {
  return new Promise((resolve) => {
    fs.readFile(path, { encoding: 'utf-8' }, (err, data) => {
      resolve(data)
    })
  })
}

function zip () {
  return new Promise((resolve) => {
    const { exec } = require('child_process')
    const kekaPath = '/Applications/Keka.app/Contents/Resources/keka7z'
    exec(`${kekaPath} a -tzip -mx9 ${destPath}/${fileName}.zip ${destPath}/${fileName}.min.p8`, (error, stdout) => {
      let bytes = stdout
        .match(/Archive size: ([\d]+) bytes/g)[0]
        .trim()
        .replace('Archive size: ','')
        .replace(' bytes','')
      console.log(`Built file '${fileName}.zip' (${bytes} bytes)`)
      bytes = Number(bytes)
      if (bytes>2048) {
        console.log(chalk`{red Warning!} You're {yellow ${Math.abs(2048-bytes)} bytes} over the limit.`)
      } else {
        console.log(chalk`You've got {green ${2048-bytes} bytes} left, good luck.`)
      }
      resolve(bytes)
    })
  })
}

function macrofy (source, macros) {
  let keywords = source.match(/(\${1}[a-z_0-9]+)/g)
  keywords = Array.from(new Set(keywords))
  keywords.sort((a, b) => b.length-a.length)
  keywords.forEach((str, i) => {
    const macro = macros[str]
    source = source.replace(new RegExp('\\$'+str.replace('$',''), 'g'), macro)
  })

  return source
}

function minify (source) {
  const reservedKeywords = ['_init', '_draw']
  const allLetters       = 'abcdefghlmnopqstuvwz'.split('')

  let keywords = source.match(/(_{1}[a-z_0-9]+)/g)
  keywords = keywords.filter((str) => !reservedKeywords.includes(str))
  keywords = Array.from(new Set(keywords))
  keywords.sort((a, b) => b.length-a.length)
  keywords.forEach((str, i) => {
    const char = allLetters[i%allLetters.length]
    const prefix = i>=allLetters.length?allLetters[Math.round(i/allLetters.length)]:''
    source = source.replace(new RegExp(str, 'g'), prefix+char)
  })

  let lines = source.split('\n')
  lines  = lines.map((line) => line.trim())
  lines  = lines.filter((line) => !line.startsWith('--'))
  lines  = lines.filter((line) => line!=='')
  source = lines.join(' ')

  return source
}

async function build () {
  let source = await readFile(`${sourcePath}/index.pmeta`)

  // Macros
  delete require.cache[require.resolve(`${__dirname}/../${sourcePath}/macros.json`)]
  let macros = require(`${__dirname}/../${sourcePath}/macros.json`)

  // Resources
  let resources
  try {
    resources = await readFile(`${sourcePath}/resources.p8`)
    resources = resources.split('\n')
    const startsAt = resources.findIndex((line) => line.startsWith('__gfx__'))
    resources.splice(0, startsAt-1)
    resources = resources.map((line) => line.trim())
    resources = resources.join('\n').trim()
  } catch (err) {
    resources = false
  }

  let lines  = source.trim().split('\n')
  let files  = []

  for (let i=0;i<lines.length;i++) {
    const fileSource = await readFile(`${sourcePath}/${lines[i]}.lua`)
    files.push(fileSource.trim())
  }

  source = files.join('\n')
  source = macrofy(source, macros)
  let minified = minify(source)

  // Append resources if present
  if (resources) {
    source = [source, resources].join('\n')
    minified = [minified, resources].join('\n')
  }

  const fileHeader = `pico-8 cartridge // http://www.pico-8.com
version 18
__lua__`
  source   = [fileHeader,source].join('\n')
  minified = [fileHeader,minified].join('\n')

  await new Promise((resolve) => {
    fs.writeFile(`${destPath}/${fileName}.p8`, source, (err) => {
      console.log(`Built file '${fileName}.p8' (${source.length} bytes)`)
      resolve()
    })
  })

  return new Promise((resolve) => {
    fs.writeFile(`${destPath}/${fileName}.min.p8`, minified, (err) => {
      console.log(`Built file '${fileName}.min.p8' (${minified.length} bytes)`)
      resolve()
    })
  })
}

(async () => {
  await build()
  await zip()
  console.log(`Waiting for changes...`)
  fs.watch(sourcePath, async (curr, prev) => {
    console.log(`...`)
    console.log(`Change detected!`)
    await build()
    await zip()
    console.log(`Done!`)
  })
})()
