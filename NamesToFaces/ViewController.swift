//
//  ViewController.swift
//  NamesToFaces
//
//  Created by José Eduardo Pedron Tessele on 04/09/19.
//  Copyright © 2019 José P Tessele. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person]{
                people = decodedPeople
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        //As the default cell belongs to UIcollectionViewCell and the cell we gonna
        // use is PersonCell type, we needto cast it
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue Personcell.")
        }
        
        let person = people[indexPath.item]
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        return cell
    }
    
    @objc func removePerson(at personIndex: Int){
        people.remove(at: personIndex)
    }
    
    func pickerConfiguration(picker: UIImagePickerController, sourceType: String){
        let picker = UIImagePickerController()
        
        if sourceType == "take"{
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    @objc func addNewPerson(){
        let picker = UIImagePickerController()
        let ac = UIAlertController(title: "What you want?", message: "Take or choose a picture from gallery?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Take", style: .default){
            [weak self] _ in
            self?.pickerConfiguration(picker: picker, sourceType: "take")
        })
        ac.addAction(UIAlertAction(title: "Choose", style: .default){
            [weak self] _ in
            
            self?.pickerConfiguration(picker: picker,sourceType: "choose")
        })
        present(ac, animated: true)

    }
    
    @objc func rename(_ person: Person){
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Ok", style: .default){
            [weak self, weak ac] action in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.save()
            self?.collectionView.reloadData()
            
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Choose an action", message: "Do you want to remove or rename this person?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "rename", style: .default){
            [weak self] _ in
            self?.rename(person)
        })
        ac.addAction(UIAlertAction(title: "remove", style: .destructive){
            [weak self] _ in
            self?.removePerson(at: indexPath.item)
            self?.collectionView.reloadData()
        })
        present(ac, animated: true)
    }
    
    func save(){
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false){
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        }
    }
}



