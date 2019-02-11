//
//  AddPetViewController.swift
//  PetMatch
//
//  Created by Carlo Aguilar on 2/10/19.
//  Copyright © 2019 Belatrix. All rights reserved.
//

import UIKit
import Firebase

class AddPetViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
  
  @IBOutlet weak var imagePet: UIImageView!
  @IBOutlet weak var typePicker: UIPickerView!
  @IBOutlet weak var genderPicker: UIPickerView!
  @IBOutlet weak var birthdatePicker: UIDatePicker!
  @IBOutlet weak var nameText: UITextField!
  @IBOutlet weak var descriptionText: UITextView!
  
  let genders = ["Male","Female"]
  let types = ["Cat","Dog", "Hamster"]
  
  // MARK: Properties
  var pets: [Pet] = []
  var user: User!
  let ref = Database.database().reference(withPath: "Pets")
  let usersRef = Database.database().reference(withPath: "Users")

  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    if pickerView == typePicker {
      return 1
    } else if pickerView == genderPicker {
      return 1
    } else {
      return 0
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView == typePicker {
      return self.genders.count
    } else if pickerView == genderPicker {
      return self.types.count
    } else {
      return 0
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView == typePicker {
      return genders[row]
    } else if pickerView == genderPicker {
      return types[row]
    } else {
      return ""
    }
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView {
    case typePicker:
      typeText.text = types[row]
    case genderPicker:
      genderText.text = age[row]

  }
  
  @IBAction func saveButton(_ sender: UIButton) {
    
    let name = self.nameText.text ?? ""
    let type = self.typePicker
    let birthdate = ""
    let about = self.descriptionText.text ?? ""
    let gender = self.genderPicker.description
    let owner = ""
    let photo = ""
    
    let pet = Pet(type: type, name: name, birthdate: birthdate, about: about, gender: gender, owner: owner, photo: photo)
    
    let petRef = self.ref.childByAutoId()
    petRef.setValue(pet.toAnyObject())
  }
  
}


