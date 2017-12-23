/*
 * Doughnut Podcast Client
 * Copyright (C) 2017 Chris Dyer
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate, DownloadManagerDelegate {
  @IBOutlet var allToggle: NSButton!
  @IBOutlet var newToggle: NSButton!
  @IBOutlet var playerView: NSToolbarItem!
  @IBOutlet weak var downloadsButton: NSToolbarItem!
  
  var downloadsViewController: DownloadsViewController?
  
  var subscribeViewController: SubscribeViewController {
    get {
      return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SubscribeViewController")) as! SubscribeViewController
    }
  }
  
  var editPodcastViewController: EditPodcastViewController {
    get {
      return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "EditPodcastViewController")) as! EditPodcastViewController
    }
  }
  
  var episodeWindowController: NSWindowController {
    get {
      return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "EpisodeWindowController")) as! NSWindowController
    }
  }
  
  var podcastWindowController: NSWindowController {
    get {
      return self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "PodcastWindowController")) as! NSWindowController
    }
  }
  
  override func windowDidLoad() {
    super.windowDidLoad()
    window?.titleVisibility = .hidden
    
    self.downloadsViewController = (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DownloadsPopover")) as! DownloadsViewController)
    
    downloadsButton.view?.isHidden = true
    Library.global.downloadManager.delegate = self
  }
  
  @IBAction func subscribeToPodcast(_ sender: Any) {
    /*let subscribeAlert = NSAlert()
    subscribeAlert.messageText = "Podcast feed URL"
    subscribeAlert.addButton(withTitle: "Ok")
    subscribeAlert.addButton(withTitle: "Cancel")
    
    let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
    input.stringValue = ""
    
    subscribeAlert.accessoryView = input
    let button = subscribeAlert.runModal()
    if button == .alertFirstButtonReturn {
      Library.global.subscribe(url: input.stringValue)
    }*/
    
    contentViewController?.presentViewControllerAsSheet(subscribeViewController)
  }
  
  @IBAction func reloadAll(_ sender: Any) {
    Library.global.reloadAll()
  }
  
  @IBAction func newPodcast(_ sender: Any) {
    let vc = editPodcastViewController
    vc.podcast = nil
    contentViewController?.presentViewControllerAsSheet(vc)
  }
  
  @IBAction func showDownloads(_ button: NSButton) {
    guard let downloadsViewController = self.downloadsViewController else { return }
    
    let popover = NSPopover()
    popover.behavior = .transient
    popover.contentViewController = downloadsViewController
    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
  }
  
  @IBAction func toggleAllEpisodes(_ sender: Any) {
    allToggle.state = .on
    newToggle.state = .off
  }
  
  @IBAction func toggleNewEpisodes(_ sender: Any) {
    allToggle.state = .off
    newToggle.state = .on
  }
  
  func downloadStarted() {
    downloadsButton.view?.isHidden = false
    self.downloadsViewController?.downloadStarted()
  }
  
  func downloadFinished() {
    if Library.global.downloadManager.queueCount < 1 {
      downloadsButton.view?.isHidden = true
    }
    
    self.downloadsViewController?.downloadFinished()
  }
  
  func windowDidResignKey(_ notification: Notification) {
    if let player = playerView.view as? PlayerView {
      player.needsDisplay = true
    }
  }
  
  func windowDidBecomeKey(_ notification: Notification) {
    if let player = playerView.view as? PlayerView {
      player.needsDisplay = true
    }
  }
  
  // Control Menu
  @IBAction func playerBackward(_ sender: Any) {
    Player.global.skipBack()
  }
  
  @IBAction func playerPlay(_ sender: Any) {
    Player.global.play()
  }
  
  @IBAction func playerForward(_ sender: Any) {
    Player.global.skipAhead()
  }
  
  @IBAction func volumeUp(_ sender: Any) {
    let current = Player.global.volume
    Player.global.volume = min(current + 0.1, 1.0)
  }
  
  @IBAction func volumeDown(_ sender: Any) {
    let current = Player.global.volume
    Player.global.volume = max(current - 0.1, 0.0)
  }
}
