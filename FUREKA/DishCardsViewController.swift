//
//  DishCardsViewController.swift
//  FUREKA
//
//  Created by Sherry Chen on 5/29/18.
//  Copyright © 2018 Sherry Chen. All rights reserved.
//

import UIKit

class DishCardsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var DishCardCollectionViewLayout: UICollectionViewFlowLayout!

    //MARK: Buttons
    @IBAction func ExitDishCardsPressed(_ sender: UIButton) {
        //Set up the live video or start the session
        instanceOfARMenuVC.configLiveVideo()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: variables
    private var indexOfCellBeforeDragging = 0
    private var dataSource = ["Chicken Parmesean","Pizza","Chocolate Ice Cream"]
    var instanceOfARMenuVC : ARMenuViewController!
    
    //MARK: lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DishCardCollectionViewLayout.minimumLineSpacing = 0
        configureCollectionViewLayoutItemSize()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureCollectionViewLayoutItemSize()
    }
    
    //MARK: private functions
    private func calculateSectionInset() -> CGFloat {
        //do we need this whole function...
        let deviceIsIpad = UIDevice.current.userInterfaceIdiom == .pad
        let deviceOrientationIsLandscape = UIDevice.current.orientation.isLandscape
        let cellBodyViewIsExpended = deviceIsIpad || deviceOrientationIsLandscape
        let cellBodyWidth: CGFloat = 207 + (cellBodyViewIsExpended ? 174 : 0)
        let inset = (DishCardCollectionViewLayout.collectionView!.frame.width - cellBodyWidth) / 4
        return inset
    }
    
    private func configureCollectionViewLayoutItemSize() {
        //let inset: CGFloat = calculateSectionInset() // This inset calculation is some magic so the next and the previous cells will peek from the sides. Don't worry about it
        let inset: CGFloat = 40 //this value needs to be changed, via trials and errors
        DishCardCollectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        DishCardCollectionViewLayout.itemSize = CGSize(width: DishCardCollectionViewLayout.collectionView!.frame.size.width - inset * 2, height: DishCardCollectionViewLayout.collectionView!.frame.size.height)
        DishCardCollectionViewLayout.collectionView!.reloadData()
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = DishCardCollectionViewLayout.itemSize.width
        let proportionalOffset = DishCardCollectionViewLayout.collectionView!.contentOffset.x / itemWidth
        return Int(round(proportionalOffset))
    }
    
    //MARK: UICollectionViewDelegate:
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>){
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        // Calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        
        // calculate conditions:
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = (indexOfCellBeforeDragging + 1 < dataSource.count) && (velocity.x > swipeVelocityThreshold)
        let hasEnoughVelocityToSlideToThePreviousCell = (indexOfCellBeforeDragging - 1 >= 0) && (velocity.x < -swipeVelocityThreshold)
        let majorCellIsTheCellBeforeDragging = (indexOfMajorCell == indexOfCellBeforeDragging)
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            
            // Here we’ll add the code to snap the next cell
            // or to the previous cell
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = DishCardCollectionViewLayout.itemSize.width * CGFloat(snapToIndex)
            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                scrollView.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            DishCardCollectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    //MARK: UICollectionViewDataSource:
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DishCardCell", for: indexPath) as! DishCardCollectionViewCell
        
        cell.configure(dish: dataSource[indexPath.row])
        
        return cell
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
