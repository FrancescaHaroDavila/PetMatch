//
//  HomeViewController.swift
//  PetMatch
//
//  Created by Francesca Valeria Haro Dávila on 2/8/19.
//  Copyright © 2019 Belatrix. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class HomeViewController: UIViewController {
    @IBOutlet weak var petCollectionView: UICollectionView!
    
    let baseArray = [1,2,3]
    var allPets: [Pet] = []
    let PetRef = Database.database().reference(withPath: "Pets")
    let storage = Storage.storage()
    
    @IBAction func logOutAction(_ sender: UIBarButtonItem) {
        
        do {
            GIDSignIn.sharedInstance()?.signOut()
            try Auth.auth().signOut()
            
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PetRef.observe(.value, with: { snapshot in
            var petsFromFirebase: [Pet] = []
            for child in snapshot.children {
                // 4
                if let snapshot = child as? DataSnapshot,
                    let pet = Pet(snapshot: snapshot) {
                    petsFromFirebase.append(pet)
                }
            }
            self.allPets = petsFromFirebase
            self.petCollectionView.reloadData()
            
            print("ESTA ES LA TAOIGJWRG: " + String(self.allPets.count))
        })
    }
    
    
    private var indexOfCellBeforeDragging = 0
    private var collectionViewFlowLayout: UICollectionViewFlowLayout {
        return petCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    
    func calculateAgeFromDateString(dateString: String) -> DateComponents{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let date: Date? = dateFormatter.date(from: dateString)
        let now = Date()
        let birthdate: Date = date ?? Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year, .month], from: birthdate, to: now)
        return ageComponents
    }
    
    func setImageFromURL(url: String){
      
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allPets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCardCell", for: indexPath) as? PetCardCell else {
            return UICollectionViewCell()
        }
        let pet = allPets[indexPath.row]
        cell.nameLabel.text = pet.name
        cell.descriptionTextView.text = pet.about
        cell.genderImageView.image = UIImage(named: pet.gender)
        let ageComponents = self.calculateAgeFromDateString(dateString: pet.birthdate)
        if ageComponents.year == 0 {
            cell.ageLabel.text = String(ageComponents.month ?? 0) + " months"
        }else{
            cell.ageLabel.text = String(ageComponents.year ?? 0) + " years and " + String(ageComponents.month ?? 0) + " months"
        }
      let storageRef = storage.reference(forURL: pet.photo)
      storageRef.getData(maxSize: 5 * 1024 *  1024) { (data, error) -> Void in
        
        if let imgData = data {
          let pic = UIImage(data: imgData)
          cell.petImageView.image = pic
        }
      }
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureCollectionViewLayoutItemSize()
    }
    
    private func configureCollectionViewLayoutItemSize() {
        let inset: CGFloat = 40
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        self.collectionViewFlowLayout.itemSize = CGSize(width: self.petCollectionView.collectionViewLayout.collectionView!.frame.size.width - inset * 2, height: self.petCollectionView.collectionViewLayout.collectionView!.frame.size.height - inset/2)
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionViewFlowLayout.itemSize.width
        let proportionalOffset = self.petCollectionView.collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let numberOfItems = self.petCollectionView.numberOfItems(inSection: 0)
        let safeIndex = max(0, min(numberOfItems - 1, index))
        return safeIndex
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        let indexOfMajorCell = self.indexOfMajorCell()
        
        let dataSourceCount = collectionView(petCollectionView!, numberOfItemsInSection: 0)
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = collectionViewFlowLayout.itemSize.width * CGFloat(snapToIndex)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)
        } else {
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            petCollectionView.collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    
   
    
    
    
}
