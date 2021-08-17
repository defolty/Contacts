//
//  ViewController.swift
//  Contacts MDH
//
//  Created by Nikita Nesporov on 17.08.2021.
//
 
import UIKit
import Contacts
import ContactsUI

struct ContactModel: Codable {
    var name: String
    var phoneNumber: String
}
 
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate, CNContactViewControllerDelegate {
     
    @IBOutlet var tableView: UITableView!
     
    var contactList = [ContactModel]()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
         
        self.fetchContactsData()
    }
    
    private func fetchContactsData() {
        print("Попытка получить доступ к контактам.")
        
        let repo = CNContactStore()
        
        repo.requestAccess(for: .contacts) { (granted, err) in
            if let errorOne = err {
                print("Не удалось получить разрешение на доступ:", errorOne)
                return
            }
            
            if granted {
                print("Доступ есть")
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    request.sortOrder = CNContactSortOrder.userDefault
                    try repo.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        
                        let phone_number = contact.phoneNumbers.first?.value.stringValue ?? ""
                        if phone_number != "" {
                            
                            let anotherName = contact.givenName + " " + contact.familyName
                            let anotherPhone = contact.phoneNumbers.first?.value.stringValue ?? ""
                            let formatedPhoneNumber = anotherPhone.replacingOccurrences(of: " ", with: "")
                            
                            let anotherContact = ContactModel(name: anotherName, phoneNumber: formatedPhoneNumber)
                            self.contactList.append(anotherContact)
                        }
                    })
                    
                    self.tableView.reloadData()
                     
                } catch let err {
                    print("Не удалось перечислить контакты:", err)
                }
                
            } else {
                print("Доступ запрещен.")
            }
        }
    }
     
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        let currentContact = contact.mutableCopy() as! CNMutableContact
        
        let controller = CNContactViewController(for: currentContact)
        controller.allowsEditing = true
        controller.contactStore = CNContactStore()
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func call(phone: String) {
        let phoneNumber = phone.replacingOccurrences(of: " ", with: "")
        let url = URL(string: "telprompt://\(phoneNumber)")
        
        guard url != nil else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
     
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let message: String = "Список контактов"
        return message
    }
     
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var customHeight = 0
        customHeight = 20
        return CGFloat(customHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let customHeight = 100
        return CGFloat(customHeight)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = self.contactList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactTableViewCell
        
        cell.nameOutlet.text = rowData.name
        cell.phoneOutlet.text = rowData.phoneNumber
        
        cell.selectionStyle = .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { 
        call(phone: contactList[indexPath.row].phoneNumber)
    }
}
  
