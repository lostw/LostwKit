//
//  ZZImagePreviewController.swift
//  Alamofire
//
//  Created by William on 2019/4/10.
//

import UIKit

public class ZZImagePreviewController: UIViewController {
    public var enableDelete = false
    public var onFinish: (([UIImage]) -> Void)?
    private var _hideNavBar = false
    var flowLayout: UICollectionViewFlowLayout!
    var photos: [UIImage]
    var currentIndex: Int {
        didSet {
            self.title = "\(currentIndex + 1)/\(self.photos.count)"
        }
    }
    var collectionView: UICollectionView!

    override public var prefersStatusBarHidden: Bool {
        return _hideNavBar
    }

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
        self.title = "\(currentIndex + 1)/\(photos.count)"

        self.view.onTouch { [unowned self] _ in
            self._hideNavBar = !self._hideNavBar
            self.navigationController?.setNavigationBarHidden(self._hideNavBar, animated: true)
            self.setNeedsStatusBarAppearanceUpdate()
        }
        // Do any additional setup after loading the view.
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if currentIndex > 0 {
            collectionView.setContentOffset(CGPoint((view.bounds.width + 20) * CGFloat(currentIndex), 0), animated: false)
        }
    }

    @objc func deletePhoto() {
        let vc = UIAlertController(title: nil, message: "要删除这张照片吗？", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "删除", style: .destructive) { _ in
            self.deleteCurrentPhoto()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        vc.addAction(deleteAction)
        vc.addAction(cancelAction)
        self.present(vc, animated: true)
    }

    func deleteCurrentPhoto() {
        photos.remove(at: currentIndex)
        if photos.isEmpty {
            navBack()
        } else {
            collectionView.reloadData()
            currentIndex = calculateCurrentIndex()
        }
    }

//    @objc func goBack() {
//        onFinish?(photos)
//        navBack()
//    }

    func calculateCurrentIndex() -> Int {
        var offsetX = collectionView.contentOffset.x
        offsetX += (view.bounds.width + 20) * 0.5
        return Int(offsetX / (view.bounds.width + 20))
    }

    func commonInitView() {
//        navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, selector: #selector(goBack))
//        UIBarButtonItem(image: self.navigationController!.navigationBar.backIndicatorImage, style: .plain, target: self, action: #selector(goBack))
        if enableDelete {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePhoto))
        }

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        flowLayout = layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentSize = CGSize(CGFloat(self.photos.count) * (self.view.bounds.width + 20), 0)
        collectionView.register(ZZImagePreviewCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(-10)
            $0.right.equalToSuperview().offset(10)
        }
    }

    override public func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            onFinish?(photos)
        }
        super.willMove(toParent: parent)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        flowLayout.itemSize = CGSize(self.view.bounds.width + 20, self.view.bounds.height)
//        collectionView.collectionViewLayout = flowLayout
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
}

extension ZZImagePreviewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ZZImagePreviewCell
        cell.bindData(image: self.photos[indexPath.row])
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ZZImagePreviewCell).previewView.setNeedsLayout()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = calculateCurrentIndex()
        if index < photos.count && currentIndex != index {
            currentIndex = index
        }
    }

}

class ZZImagePreviewCell: UICollectionViewCell {
    let previewView = ZZImagePreviewView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindData(image: UIImage) {
        previewView.image = image
    }

    func commonInitView() {
        self.addSubview(previewView)
        previewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
