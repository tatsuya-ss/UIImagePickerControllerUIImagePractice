//
//  ViewController.swift
//  UIImage+UIImagePicker
//
//  Created by 坂本龍哉 on 2021/09/18.
//

import UIKit
import Photos

struct FirebaseStorage {
    var imageData: Data?
}

struct Cell {
    var image: UIImage?
}

final class ViewController: UIViewController {

    @IBOutlet weak var collecitonView: UICollectionView!
    @IBOutlet weak var displayImageView: UIImageView!

    private var storages: [FirebaseStorage] = []
    private var cells: [Cell] = [Cell(image: nil)]
    private var selectedIndexPath: IndexPath = [0, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    @IBAction private func addtionalButtonDidTapped(_ sender: Any) {
        cells.append(Cell(image: nil))
        let insertIndexPath = IndexPath(item: cells.count - 1,
                                        section: 0)
        collecitonView.insertItems(at: [insertIndexPath])
        collecitonView.scrollToItem(at: insertIndexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
    }
    
    @IBAction private func selectPhotoButtonDidTapped(_ sender: Any) {
        getPhotosAuthorization()
    }
    
    @IBAction private func saveButtonDidTapped(_ sender: Any) {
        cells.forEach { convertImageToData(image: $0.image) }
    }
    @IBAction private func displayPhotoButtonDidTapped(_ sender: Any) {
        guard let imageData = storages.first?.imageData else { return }
        displayImageView.image = UIImage(data: imageData)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { dismiss(animated: true, completion: nil) }
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        cells[selectedIndexPath.item].image = selectedImage
        collecitonView.reloadItems(at: [selectedIndexPath])
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier,
                                                            for: indexPath) as? CollectionViewCell
        else { fatalError("セルがありません") }
        if let image = cells[indexPath.item].image {
            cell.configure(image: image)
        } else {
            cell.configure(image: UIImage(systemName: "timer")!)
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
}

// MARK: - imagePicker
extension ViewController {
    
    private func getPhotosAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.showImagePickerController()
                }
            case .denied:
                DispatchQueue.main.async {
                    self.showPhotosAuthorizationDeniedAlert()
                }
            default:
                break
            }
        }
    }
    
    private func showPhotosAuthorizationDeniedAlert() {
        let alert = UIAlertController(title: "写真へのアクセスを許可しますか？",
                                      message: nil,
                                      preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "設定画面へ",
                                           style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL,
                                      options: [:],
                                      completionHandler: nil)
        }
        let closeAction = UIAlertAction(title: "キャンセル",
                                        style: .cancel,
                                        handler: nil)
        [settingsAction, closeAction]
            .forEach { alert.addAction($0) }
        present(alert,
                animated: true,
                completion: nil)
    }
    
    private func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController,
                animated: true,
                completion: nil)
    }

}

// MARK: - setup
extension ViewController {
    
    private func setupCollectionView() {
        collecitonView.register(CollectionViewCell.nib,
                                forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collecitonView.collectionViewLayout = CustomTimerCollectionViewFlowLayout()
        collecitonView.dataSource = self
        collecitonView.delegate = self
    }

    private func convertImageToData(image: UIImage?) {
        guard let image = image,
              let selectedImageData = image.jpegData(compressionQuality: 1.0) else { return }
        storages.append(FirebaseStorage(imageData: selectedImageData))
    }
    
}

// MARK: - UICollectionViewFlowLayout
final class CustomTimerCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        guard let cv = collectionView else { return }
        scrollDirection = .horizontal

        let availableWidth = cv.bounds.inset(by: cv.layoutMargins).size.width
        let cellWidth = (availableWidth / 3).rounded(.down)
                
        let cellHeight = cv.layer.frame.height * 0.9
        
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
}
