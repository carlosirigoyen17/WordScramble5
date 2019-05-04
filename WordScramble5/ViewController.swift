//
//  ViewController.swift
//  WordScramble5
//
//  Created by Carlos Irigoyen on 5/3/19.
//  Copyright © 2019 Carlos Irigoyen. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
  var allWords = [String]()
  var usedWords = [String]()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startGame))
    
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
      if let startWords = try? String(contentsOf: startWordsURL) {
        allWords = startWords.components(separatedBy: "\n")
      }
    }
    
    if allWords.isEmpty {
      allWords = ["silkworm"]
    }
    
    startGame()
  }

  @objc func startGame() {
    title = allWords.randomElement()
    usedWords.removeAll(keepingCapacity: true)
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return usedWords.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
    cell.textLabel?.text = usedWords[indexPath.row]
    return cell
  }
  
  @objc func promptForAnswer() {
    let alertController = UIAlertController(title: "Insert", message: nil, preferredStyle: .alert)
    alertController.addTextField()
    let submitAction = UIAlertAction(title: "Save", style: .default) {
      [weak self, weak alertController] _ in
      guard let answer = alertController?.textFields?[0].text else { return }
      self?.submit(answer)
    }
    
    alertController.addAction(submitAction)
    present(alertController, animated: true)
  }

  func submit(_ answer: String) {
    print(answer)
    
    var errorTitle: String
    var errorMessage: String
    
    let lowerAnswer = answer.lowercased()
    if isPossible(word: lowerAnswer) && !lowerAnswer.isEmpty {
      if isOriginal(word: lowerAnswer) {
        if isReal(word: lowerAnswer) {
          usedWords.insert(lowerAnswer, at: 0)
          let indexPath = IndexPath(row: 0, section: 0)
          tableView.insertRows(at: [indexPath], with: .automatic)
          
          return
        } else {
          errorTitle = "Not Real"
          errorMessage = "No es real"
        }
      } else {
        errorTitle = "Not Original"
        errorMessage = "No es original"
      }
    } else {
      errorTitle = "Not Possible"
      errorMessage = "No es posible"
    }
    
    let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
  }
  
  func isPossible(word: String) -> Bool {
    guard var tempWord = title?.lowercased() else { return false }
    
    for letter in word {
      if let position = tempWord.firstIndex(of: letter) {
        tempWord.remove(at: position)
      } else {
        return false
      }
    }
    
    return true
  }
  
  func isOriginal(word: String) -> Bool {
    return !usedWords.contains(word)
  }
  
  func isReal(word: String) -> Bool {
    
    if word.count <= 2 { return false }
    
    guard let titleAux = title else {
      return false
    }
    if word == titleAux.prefix(3) {
      print("son igules")
      return false
    }
    
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    print(range)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    print(misspelledRange)
    print(misspelledRange.location)
    return misspelledRange.location == NSNotFound
  }

}

