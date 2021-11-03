import UIKit

class RandomImage: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
// Counter variable created to store pageCount
    var counter = 1
    
// Main Global Array to store all properties
    var CollectionStorageArray : [[String: Any]] = []
    
// Outlet of collectionView in RandomImage
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
// To hide Navigation Bar Bottom Border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
// Setting up collectionview Delegate and Datasource
        collectionViewOutlet.delegate = self
        collectionViewOutlet.dataSource = self
        
// Setting up Url and calling GetData Function
        let url = "https://pixabay.com/api/?key=6535859-9848eef233ce93e8bfb33e5a6&per_page=20&page=\(counter)"
        getData(from : url)
    }
    
// Action called to save image file on resp. ceollectionview cell
    @IBAction func SaveImageBtnTappedInCollCell(_ sender: UIButton) {
        print("tag->\(sender.tag)")
        let index = sender.tag
        let strImgPath = CollectionStorageArray[index]["largeImageURL"]! as! String
        setCustomImage(strImgPath)
    }

// Function called from SaveImageBtnTappedInCollCell
        func setCustomImage(_ imgURLString: String?) {
            guard let imageURLString = imgURLString else {
                return
            }
            DispatchQueue.global().async { [weak self] in
                let data = try? Data(contentsOf: URL(string: imageURLString)!)
                DispatchQueue.main.async {
                    if let imgData = data,
                       let downloadedImg = UIImage(data: imgData){
                        UIImageWriteToSavedPhotosAlbum(downloadedImg, self, #selector(self?.image(_: didFinishSavingWithError: contextInfo:)), nil)
                    }
                }
            }
        }

// Function called from setCustomImage
        @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?,
                         contextInfo: UnsafeRawPointer){
            if let error = error{
                let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
            }
            else{
                let ac = UIAlertController(title: "Image Saved!", message: "Your Image has been saved to Photos Library.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true, completion: nil)
            }
        }

// WillDisplay - For Pagination - fetch only 20 records
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == CollectionStorageArray.count - 1{
            moreData()
        }
    }
    
// Function called from ViewDidLoad after creating api
    func getData(from url : String ){
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { [self]data, response, error in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else {
                do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        if let postsData = json["hits"] as? [[String:Any]] {
                            self.CollectionStorageArray.append(contentsOf: postsData)
                            DispatchQueue.main.async {
                                self.collectionViewOutlet.reloadData()
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }).resume()
    }
    
// Stub Generated function which are compulsory in datasource & created explicitly
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return CollectionStorageArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionViewCell
            let row = indexPath.row
            cell.setupData(obj:CollectionStorageArray[row],row:row)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "DetailsViewController") as? DetailsViewController
        vc?.indexId = indexPath.row
        vc?.DetailsStorage = CollectionStorageArray
        vc?.labelOnDetailScreen = self.CollectionStorageArray[indexPath.row]["tags"] as! String
        vc?.imgURL = CollectionStorageArray[indexPath.row]["largeImageURL"]! as! String
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let collectionWidth = collectionView.bounds.width
        return CGSize(width: ((collectionWidth/2)-30), height: (collectionView.bounds.size.height/2.7)-30)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
// MoreData will be called from willDisplay Delegate Function
    func moreData(){
            
// Increment pageCount / by updating counter
    counter += 1
                
// Recreate URL with new parameter values
    let url = "https://pixabay.com/api/?key=6535859-9848eef233ce93e8bfb33e5a6&per_page=20&page=\(counter)"
                
// Function to start Api calling and getting response
    getData(from : url)
    }
}


