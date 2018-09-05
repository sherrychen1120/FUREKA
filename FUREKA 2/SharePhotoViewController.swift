//
//  SharePhotoViewController.swift
//  FUREKA
//
//  Created by Sherry Chen on 5/27/18.
//  Copyright © 2018 Sherry Chen. All rights reserved.
//

import UIKit

class SharePhotoViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        //Set up navigation bar style
        let textAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Share Photo"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
