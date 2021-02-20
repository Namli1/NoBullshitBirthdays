//
//  CompanionDetailTableViewController.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 30.08.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit
import ChameleonFramework

class CompanionDetailTableViewController: UITableViewController, UITextViewDelegate {

    var companion: Companion?
    
    var hiddenCells: [Int]? = [Int]()
    
    var navBarTintColor: UIColor = .black
    
    var headerView: UIView!
    private let kTableHeaderHeight:CGFloat = 300.0
    private let kTableHeaderCutAway: CGFloat = 80.0
    var headerMaskLayer: CAShapeLayer!
    private var shadowLayer: CAShapeLayer!
    
    @IBOutlet weak var headerProfileImage: UIImageView!
    @IBOutlet weak var headerProfileImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerProfileImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTitleView: UIView!
    @IBOutlet weak var headerTitleSubview: UIView!
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var headerBirthdayLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var frequencySlider: UISlider!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var companionBirthday: UILabel!
    @IBOutlet weak var phoneNumbersContainerStackView: UIStackView!
    @IBOutlet weak var socialAccountsContainerStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        customizeNavBar()
        strechtyHeaderSetup()
        tableView.reloadData()
        
        
        self.navigationController!.navigationBar.isTranslucent = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeCompanion), name: Notification.Name("didChangeCompanion"), object: nil)
    }

    //MARK: - Text View Delegate Methods
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let toBeHiddenCells = hiddenCells {
            for hiddenIndex in toBeHiddenCells {
                if indexPath.row == hiddenIndex {
                    return 0
                }
            }
        }
        
        return UITableView.automaticDimension
        
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        if let companionForm = self.storyboard?.instantiateViewController(identifier: "companionForm") as? CompanionFormViewController {
            let navVC = UINavigationController(rootViewController: companionForm)
            self.present(navVC, animated: true, completion: nil)
            companionForm.companionObject = companion
        }
        
    }
    
    

    func setupUI() {
        
        //tableView.separatorStyle = .none
        
        //Notes text View Setup to size to fit text
        notesTextView.isEditable = false
        notesTextView.sizeToFit()
        notesTextView.delegate = self
        
        //Frequency Slider/Label setup
        frequencySlider.setThumbImage(UIImage(), for: .normal)
        
        if let companion = companion {
            navigationItem.title = companion.name
            //Companion Photo
            if let photoData = companion.value(forKey: "photo") as? Data {
                headerProfileImage.image = UIImage(data: photoData)
                
            } else {
                headerProfileImage.image = UIImage(systemName: "person")
                headerProfileImage.tintColor = .black
            }

            ///Companion Name + Birthday
            self.headerNameLabel.text = companion.name
            if let birthday = companion.birthday?.toString() {
                self.headerBirthdayLabel.text = "🎁: \(birthday)"
            } else {
                self.headerBirthdayLabel.text = ""
            }
            
            ///Companion Phone Number
            if let phoneNumbers = companion.phoneNumbers, !phoneNumbers.isEmpty {
                //First remove all existing subviews to then replace them
                for subView in phoneNumbersContainerStackView.arrangedSubviews {
                    subView.removeFromSuperview()
                }
                
                
                //Display phone numbers(!) here
                
                for (index, number) in phoneNumbers.enumerated() {
                    let numberView = UINib(nibName: "PhoneNumberStackView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? PhoneNumberStackView
                    if let stackView = numberView {
                        stackView.phoneNumberCount.text = "\(index+1)📱:"
                        stackView.phoneNumberButton.setTitle("\(number)", for: .normal)
                        phoneNumbersContainerStackView.addArrangedSubview(stackView)
}
                }
                
            } else {
                hiddenCells?.append(0)
            }
            
            ///Companion E-Mail
            if let email = companion.email {
                self.emailLabel.text = email
            } else {
                hiddenCells?.append(1)
            }
            
            ///Companion Address
            if let address = companion.address {
                let street = address.street
                let postalCode = address.postalCode
                let city = address.city
                let state = address.state
                let country = address.country
                
                self.addressLabel.text = "\(street ?? "") \n" +
                                        "\(postalCode ?? "") \(city ?? "") \n" +
                                        "\(state ?? "") \n" +
                                        "\(country ?? "")"
            } else {
                hiddenCells?.append(2)
            }

            ///Companion Social Accounts
            if let socialAccounts = companion.socialAccounts {
                //First, delete all subviews to then replace them
                for subView in socialAccountsContainerStackView.arrangedSubviews {
                    subView.removeFromSuperview()
                }
                
                for array in socialAccounts.enumerated() {
                    let accountStackView = UINib(nibName: "SocialAccountStackView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? SocialAccountsStackView
                    
                    if let stackView = accountStackView {
                        stackView.platform = array.element[0]
                        stackView.userName = array.element[1]
                      socialAccountsContainerStackView.addArrangedSubview(stackView)
                    }
                }
            } else {
                print("no accounts found called")
                hiddenCells?.append(3)
            }
            
            ///Companion Contacting Frequency
            if companion.contactingFrequency != 0 {
                let frequency = companion.contactingFrequency
                frequencySlider.minimumValue = 0
                frequencySlider.maximumValue = 365
                if frequency < 33 {
                    frequencySlider.value = Float(frequency*2)
                } else {
                    frequencySlider.value = Float(frequency)
                }
                
                
                frequencyLabel.text = turnNumberIntoContactingFrequency(number: Int(frequency))
                
                
            } else {
                hiddenCells?.append(5)
            }
            
            
            ///Companion Notes
            if let notes = companion.notes {
                notesTextView.text = notes
            } else {
                hiddenCells?.append(7)
            }
            
        }

        
    }
    
    //MARK: - Notification Center Methods
    
    @objc func didChangeCompanion() {
        print("did change companion")
        self.tableView.reloadData()
        tableView.layoutSubviews()
        tableView.layoutIfNeeded()
        setupUI()
    }
    
    //MARK: - Navigation Bar Customization
    func customizeNavBar() {
        let navBar = self.navigationController?.navigationBar
                
        if let image = headerProfileImage.image {
            let backgroundColor = UIColor(averageColorFrom: image)
            navBarTintColor = ContrastColorOf(backgroundColor, returnFlat: true)
        }
        
        //TODO: (Make a circle around the bar button items)
        
        self.navigationItem.title = ""
        navBar?.tintColor = navBarTintColor
        
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = navBarTintColor
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    func strechtyHeaderSetup() {
        
        var prefersStatusBarHidden: Bool { return true }
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0.0, y: -kTableHeaderHeight)
        
        headerTitleView.layer.shadowRadius = 5
        headerTitleView.layer.shadowColor = UIColor.gray.cgColor
        headerTitleView.layer.shadowOffset = CGSize(width: 2, height: 2)
        headerTitleView.layer.shadowOpacity = 0.4
        headerTitleView.layer.cornerRadius = 20
        headerTitleView.translatesAutoresizingMaskIntoConstraints = false
        
        headerTitleSubview.layer.cornerRadius = 20
        headerTitleSubview.layer.masksToBounds = true
        headerTitleSubview.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //header View Bounce
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
         if tableView.contentOffset.y < -kTableHeaderHeight {
                    headerRect.origin.y = tableView.contentOffset.y
                    headerRect.size.height = -tableView.contentOffset.y
               
         }
                
        headerView?.frame = headerRect
        
        //TODO: Make nav bar background blurry on scroll
        let contentOffsetY = tableView.contentOffset.y / 200
        
        if contentOffsetY > -0.7 {
            UIView.animate(withDuration: 0.5) {
                self.navigationController?.navigationBar.tintColor = .black
                self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = .black
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.navigationController?.navigationBar.tintColor = self.navBarTintColor
                self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = self.navBarTintColor
            }
            
        }
        
    }
    
    
}
