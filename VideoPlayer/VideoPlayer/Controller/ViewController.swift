//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Sankaranarayana Settyvari on 23/09/20.
//

import UIKit
import Photos
import AVKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var videoListTableview: UITableView!
    var videoAssets : NSMutableArray = NSMutableArray()
    var videoBookMarkArray : NSMutableArray = NSMutableArray()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.videoListTableview.dataSource = self
        self.videoListTableview.delegate = self
        checkAuthorizationForPhotoLibraryAndGet()
        
        //======================== Fetching BookMarks from Userdefaults =============================//
        self.appDelegate?.defaults = UserDefaults.standard
        if((self.appDelegate?.defaults.object(forKey: "BookMarks")) != nil)
        {
            let array:NSArray = self.appDelegate?.defaults.object(forKey: "BookMarks") as! NSArray
            self.videoBookMarkArray = array.mutableCopy() as! NSMutableArray
        }
       
    }

    //=================== Fetching Videos from PhotoLibrary =================================//
    private func getPhotosAndVideos(){

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)

        
        let allVideo = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        allVideo.enumerateObjects { (asset, index, bool) in
             
            let imageManager = PHCachingImageManager()
            imageManager.requestAVAsset(forVideo: asset, options: nil, resultHandler: { [self] (asset, audioMix, info) in
                if asset as? AVURLAsset != nil {
                    let avasset = asset as? AVURLAsset
                    let urlVideo = avasset!.url.absoluteString
                    self.videoAssets.add(urlVideo)
                    //print(urlVideo)
                    DispatchQueue.main.async {
                        self.videoListTableview.reloadData()
                    }

                }
            })

        }
        
        
    }

    //================== Check for Authorization to access PhotoLibrary =====================//
    private func checkAuthorizationForPhotoLibraryAndGet(){
        let status = PHPhotoLibrary.authorizationStatus()

        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            getPhotosAndVideos()
        }else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in

                if (newStatus == PHAuthorizationStatus.authorized) {
                        self.getPhotosAndVideos()
                }else {

                }
            })
        }
    }
    
    
    //====================  Tableview datasource methods  ============================//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.videoAssets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        
        let urlString = self.videoAssets[indexPath.row]
        
        cell.videoImageThumbnail.image = self.generateThumnail(url: URL(string: urlString as! String)!)
        
        cell.bookmark.addTarget(self, action: #selector(bookMarkButtonClicked(_:)), for: .touchUpInside)
        if(self.videoBookMarkArray.contains(urlString))
        {
            cell.bookmark.setImage(UIImage(named: "Star"), for: .normal)
        }
        else
        {
            cell.bookmark.setImage(UIImage(named: "No_Star"), for: .normal)
        }
        cell.bookmark.tag = indexPath.row
        return cell
        
    }
    
    
    @objc func bookMarkButtonClicked(_ sender: UIButton) {

        
        let urlString = self.videoAssets[sender.tag]
        if(self.videoBookMarkArray.contains(urlString))
        {
            let getIndex = self.videoBookMarkArray.index(of: urlString)
            self.videoBookMarkArray.removeObject(at: getIndex)
        }
        else
        {
            self.videoBookMarkArray.add(urlString)
        }
        
        //======================= Storing Bookmark videos locally into Userdefaults ================//
        self.appDelegate!.defaults = UserDefaults.standard
        self.appDelegate!.defaults.set(self.videoBookMarkArray, forKey: "BookMarks")
        self.appDelegate?.defaults.synchronize()
        self.videoListTableview.reloadData()
    }
    
    //========================== Generating thumbnail of video ===============================//
    func generateThumnail(url : URL) -> UIImage?{
        let asset: AVAsset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time        : CMTime = CMTimeMake(value: 1, timescale: 30)
        let img         : CGImage
        do {
            try img = assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let frameImg: UIImage = UIImage(cgImage: img)
            return frameImg
        } catch {

        }
        return nil
    }
    
    //=====================  Tableview delegate methods ===================================//
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let url = self.videoAssets[indexPath.row]
        playVideo(url: url as! URL)
    }
    
    //================= Playing video using AVPlayer ======================================//
    func playVideo(url:URL) {
        
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: url)
        playerVC.player?.play()
        self.present(playerVC, animated: true, completion: nil)
    }
    
}

