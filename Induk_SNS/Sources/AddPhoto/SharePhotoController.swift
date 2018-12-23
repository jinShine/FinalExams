//
//  SharePhotoController.swift
//  Induk_SNS
//
//  Created by 승진김 on 18/12/2018.
//  Copyright © 2018 seungjin. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleShare() {
        guard let caption = textView.text, !caption.isEmpty else { return }
        guard let image = selectedImage else { return }
        
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
       
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error != nil {
                print("******************************************************")
                print(" <이미지 업로드 실패> \n\t")
                print("******************************************************")
                
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let error = error {
                    print("******************************************************")
                    print(" <이미지 URL 다운로드 에러> \n\t", error)
                    print("******************************************************")
                    return
                }
                
                guard let imageURL = downloadURL else { return }
                print("******************************************************")
                print(" <Share 이미지 업로드 성공> \n\t", imageURL)
                print("******************************************************")
                
                //데이터베이스에 url저장
                self.saveToDatabaseWithImageUrl(imageUrl: imageURL.absoluteString)
            })
        }
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let postImage = selectedImage else { return }
        guard let caption = textView.text else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (error, ref) in
            if let error = error {
                
                self.navigationItem.rightBarButtonItem?.isEnabled = true // 활성화
                
                print("******************************************************")
                print(" <저장 이미지 데이터베이스에 저장 실패> \n\t", error)
                print("******************************************************")
            }
            
            print("******************************************************")
            print(" <데이터베이스에 이미지 저장 성공> \n\t")
            print("******************************************************")
            
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
}
