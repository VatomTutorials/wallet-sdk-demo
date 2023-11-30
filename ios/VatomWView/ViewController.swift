//
//  ViewController.swift
//  VatomWView
//
//  Created by Sebastian Sanchez on 23/01/23.
//

import UIKit
import vatom_wallet_sdk

class ViewController: UIViewController, UIScrollViewDelegate {
    var vatom: VatomWallet?
    let floatingButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        Get the access token & refresh token after the token-exchange and pass it to the VatomWallet
        let vatomAccessToken = "eyJh.abc.123"
        
        let vatomConfigFeatures: [String: Any] = [
            "hideNavigation": false,
            "hideTokenActions": true,
            "disableNewTokenToast": true,
            "scanner": ["enabled": false],
            "pageConfig": [
                "theme": [
                    "header": ["logo": "https://resources.vatom.com/3UewHF0ge9/vdev.png"],
                    "iconTitle": [:],
                    "icon": [:],
                    "main": [:],
                    "emptyState": [:],
                    "mode": "dark",
                    "pageTheme": "dark",
                ],
                "text": ["emptyState": ""],
                "features": [
                    "notifications": [:],
                    "card": [:],
                    "footer": [
                        "enabled": true,
                        "icons": [
                            [
                                "src": "https:sites.vatom.com/3UewHF0ge9",
                                "title": "Home",
                                "id": "home",
                            ],
                        ],
                    ],
                    "vatom": [:],
                ],
            ],
        ]
        
        
        self.vatom = VatomWallet(businessId: "3UewHF0ge9", accessToken:vatomAccessToken,view: self.view, config: vatomConfigFeatures)
        view.addSubview(vatom!)
        
        vatom?.scrollView.delegate = self
        vatom?.scrollView.bounces = false
        vatom?.scrollView.bouncesZoom = false
        
        vatom?.load()
        
        // Setup the floating button
        setupFloatingButton()
    }
    
    private func setupFloatingButton() {
        // Set the button image, if you have an image asset
        // floatingButton.setImage(UIImage(named: "YourButtonImage"), for: .normal)
        
        // Or set a title for the button
        floatingButton.setTitle("U", for: .normal)
        
        // Style the button
        floatingButton.backgroundColor = .systemBlue
        floatingButton.layer.cornerRadius = 25 // Half the height to create a circular shape
        
        // Add targets to the button
        floatingButton.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        
        // Disable autoresizing masks, enable autolayout
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the button to the view
        view.addSubview(floatingButton)
        
        // Set constraints for the button (e.g., bottom right corner)
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            floatingButton.widthAnchor.constraint(equalToConstant: 50),
            floatingButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func floatingButtonTapped()   {
        
        
        Task {
            try await vatom?.navigateToTab("Connect")
        }
    }
    
    private func getUser (){
        Task {
            if let userData = await vatom?.getUser()  {
                // Now that we have casted userData to a dictionary, we can access its "name" key
                
                // Show an alert with the user's name
                print(userData)
                let alertController = UIAlertController(
                    title: "User Found",
                    message: "Hello, \(userData.name)!",
                    preferredStyle: .alert
                )
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okAction)
                present(alertController, animated: true)
                
            } else {
                print("Could not retrieve user data.")
            }
        }
    }
    
    private func isLoggedIn (){
        Task {
            if let isLoggedIn = await vatom?.isLoggedIn()  {
                print("isLoggedIn",isLoggedIn)
                // Now that we have casted userData to a dictionary, we can access its "name" key
                // Show an alert with the user's name
                
                let alertController = UIAlertController(
                    title: "Is logged in?",
                    message: "\(isLoggedIn)!",
                    preferredStyle: .alert
                )
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okAction)
                present(alertController, animated: true)
                
            } else {
                print("Could not retrieve user data.")
                
                
            }
        }
    }
    
    private func navigate(_ to: String) {
        Task {
            try await vatom?.navigateToTab(to)
        }
    }
    
    private func listTokens() {
        Task {
            let tokens =  try await self.vatom?.listTokens()
            let alertController = UIAlertController(
                title: "Tokens",
                message: "You got, \(tokens?.count) tokens!",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            present(alertController, animated: true)
            
        }
    }
    
    func trashFirstToken  (){
        Task {
            let tokens =  try await self.vatom?.listTokens()
            if let firstToken = tokens?.first as? [String : Any?] {
                if let id = firstToken["id"] as? String {
                    await self.vatom?.trashToken(tokenId: id)
                }
                
            }
            
        }
    }
    
    
    
    
    
    
    // MARK: - Action Handlers
    @objc func showActionSheet() {
        let actionSheet = UIAlertController(title: "Select an Option", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Navigate to Connect", style: .default, handler: { _ in
            self.navigate("Connect")
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Navigate to Wallet", style: .default, handler: { _ in
            self.navigate("Wallet")
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Navigate to Map", style: .default, handler: { _ in
            self.navigate("Map")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Navigate to Home", style: .default, handler: { _ in
            self.navigate("Home")
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Get User", style: .default, handler: { _ in
            self.getUser()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "How many tokens?", style: .default, handler: { _ in
            self.listTokens()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "isLoggedIn?", style: .default, handler: { _ in
            self.isLoggedIn()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Trash first token", style: .default, handler: { _ in
            self.trashFirstToken()
        }))
        
        
        
        // Cancel action
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(actionSheet, animated: true)
    }
    
}


