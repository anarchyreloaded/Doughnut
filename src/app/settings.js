var electron = require('electron')
var path = require('path')
var jsonfile = require('jsonfile')
var fs = require('fs')
import Logger from './logger'

class Settings {
  constructor() {
    this.defaults = {
      firstLaunch: true,
      libraryPath: path.join(electron.app.getPath('music'), "Doughnut")
    }

    Logger.log(`Settings file: ${this.settingsFile()}`)

    this.loaded = false
  }

  settingsPath() {
    return electron.app.getPath('userData')
  }

  isProduction() {
    return process.env.NODE_ENV === 'production';
  }

  settingsFile() {
    if (this.isProduction()) {
      return path.join(this.settingsPath(), '/Doughnut.json')
    } else {
      return path.join(this.settingsPath(), `/Doughnut_${process.env.NODE_ENV}.json`)
    }
  }

  save() {
    jsonfile.writeFileSync(this.settingsFile(), this.loaded)
  }

  load() {
    this.loaded = this.defaults

    if (!fs.existsSync(this.settingsFile())) {
      this.save()
    }

    this.loaded = jsonfile.readFileSync(this.settingsFile())
  }

  loadIfNeeded() {
    if (!this.loaded) {
      this.load()
    }
  }

  get(key) {
    this.loadIfNeeded()
    return this.loaded[key]
  }
}

export default new Settings()