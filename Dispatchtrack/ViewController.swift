//
//  ViewController.swift
//  Dispatchtrack
//
//  Created by surendra kumar k on 19/08/20.
//  Copyright © 2020 surendra kumar k. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var studentsArray = [Student]()
    var studentsObj = [StudentObj]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.loadCat()
        if self.studentsArray.isEmpty {
            self.loadfromJsonInitial()
        }

    }
    
    func loadfromJsonInitial()
    {
        self.studentsObj = self.loadJson(filename: "Students")!
        DispatchQueue.global(qos: .background).async {
            for eachStudentObj in self.studentsObj
            {
                let newCategory = Student(context: self.context)
                newCategory.name = eachStudentObj.name
                newCategory.id = Int64(truncating: NSNumber(integerLiteral: eachStudentObj.id!))
                self.studentsArray.append(newCategory)
            }
            self.saveCat()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    
    func loadJson(filename fileName: String?) -> [StudentObj]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let rootDic = try JSONDecoder().decode(StudentsModel.self, from: data)
                return rootDic.students
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    
    @IBAction func reload(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    
    func saveCat()
    {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadCat()
    {
        let request : NSFetchRequest<Student> = Student.fetchRequest()
        do {
            self.studentsArray =  try context.fetch(request)
        } catch  {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Student", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newCategory = Student(context: self.context)
            newCategory.name = textField.text ?? ""
            newCategory.id = Int64(truncating: NSNumber(integerLiteral: self.studentsArray.count + 1))
            self.studentsArray.append(newCategory)
            self.saveCat()
        }
        alert.addAction(action)
        alert.addTextField { (tf) in
            textField = tf
            textField.placeholder = "Student Name"
        }
        present(alert, animated: true, completion: nil)
        
    }
    
}



extension ViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let cat = self.studentsArray[indexPath.row]
        cell.textLabel?.text = cat.name ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(self.studentsArray[indexPath.row])
            self.studentsArray.remove(at: indexPath.row)
            self.saveCat()
        }
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentObjUpdate = self.studentsArray[indexPath.row]
        var textField = UITextField()
        let alert = UIAlertController(title: "Update Student", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            studentObjUpdate.name = textField.text ?? ""
            studentObjUpdate.id = Int64(truncating: NSNumber(integerLiteral: indexPath.row))
            self.saveCat()
        }
        alert.addAction(action)
        alert.addTextField { (tf) in
            textField = tf
            textField.placeholder = "Student Name"
        }
        present(alert, animated: true, completion: nil)
    }

}
