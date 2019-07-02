//
//  ZZImagePreviewController.swift
//  Alamofire
//
//  Created by William on 2019/4/10.
//

import UIKit

public class ZZImagePreviewController: UIViewController {
    public var enableDelete = false
    public var showTitle = true
    public var onFinish: (([UIImage]) -> Void)?
    public var onPhotoUrlFinish: (([String]) -> Void)?
    private var _hideNavBar = false {
        didSet {
            if !_hideNavBar {
                collectionView.snp.updateConstraints {
                    $0.top.equalToSuperview().offset(-STATUSBAR_HEIGHT - 44)
                }
            } else {
                collectionView.snp.updateConstraints {
                    $0.top.equalToSuperview().offset(0)
                }
            }
            self.navigationController?.setNavigationBarHidden(self._hideNavBar, animated: true)
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    var flowLayout: UICollectionViewFlowLayout!
    var photos: [UIImage]
    var photoUrls: [String]
    var isUrl = false
    var currentIndex: Int {
        didSet {
            if showTitle {
                self.title = "\(currentIndex + 1)/\(self.photos.count > 0 ? self.photos.count : self.photoUrls.count)"
            }
        }
    }
    var collectionView: UICollectionView!

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if !_hideNavBar {
            self.navigationController?.navigationBar.barStyle = .default
            return .default
        } else {
            return .lightContent
        }
    }

    public init(photos: [UIImage], currentIndex: Int) {
        self.photos = photos
        self.photoUrls = []
        self.currentIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
    }

    public init(photoUrls: [String], currentIndex: Int) {
        self.isUrl = true
        self.photos = []
        self.photoUrls = photoUrls
        self.currentIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        commonInitView()
        if showTitle {
            self.title = "\(currentIndex + 1)/\(isUrl ? self.photoUrls.count : self.photos.count)"
        }

        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        self.view.onTouch { [weak self] _ in
            guard let self = self else { return }
            self._hideNavBar = !self._hideNavBar
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
        if photos.isEmpty && photoUrls.isEmpty {
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
        layout.sectionInset = [0, 0, 0, 0]
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = [SCREEN_WIDTH + 20, SCREEN_HEIGHT]
        flowLayout = layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentSize = CGSize(CGFloat(isUrl ? self.photoUrls.count : self.photos.count) * (self.view.bounds.width + 20), 0)
        collectionView.register(ZZImagePreviewCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-STATUSBAR_HEIGHT - 44)
            $0.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(-10)
            $0.right.equalToSuperview().offset(10)
        }
    }

    override public func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            if isUrl {
                onPhotoUrlFinish?(photoUrls)
            } else {
                onFinish?(photos)
            }
        }
        super.willMove(toParent: parent)
    }

}

extension ZZImagePreviewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isUrl ? self.photoUrls.count : self.photos.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ZZImagePreviewCell
        if isUrl {
            cell.bindUrl(url: self.photoUrls[indexPath.row])
        } else {
            cell.bindData(image: self.photos[indexPath.row])
        }

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ZZImagePreviewCell).previewView.setNeedsLayout()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = calculateCurrentIndex()
        if index < (isUrl ? photoUrls.count : photos.count) && currentIndex != index {
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

    func bindUrl(url: String) {
        previewView.imageUrl = url
    }

    func commonInitView() {
        self.addSubview(previewView)
        previewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
