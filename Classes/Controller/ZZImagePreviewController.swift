//
//  ZZImagePreviewController.swift
//  Alamofire
//
//  Created by William on 2019/4/10.
//

import UIKit

public class ZZImagePreviewController: UIViewController {
    public var enableDelete = false
    public var onFinish: (([UIImage])->Void)?
    
    var photos: [UIImage]
    var currentIndex: Int
    var collectionView: UICollectionView!
    
    
    public init(photos: [UIImage], currentIndex: Int) {
        self.photos = photos
        self.currentIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        commonInitView()
        // Do any additional setup after loading the view.
    }
    
    func commonInitView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ZZImagePreviewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}

class ZZImagePreviewCell: UICollectionViewCell {
    
}
