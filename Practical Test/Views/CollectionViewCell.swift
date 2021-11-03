import UIKit

// Collection View Cell in Random Image
class CollectionViewCell: UICollectionViewCell{

// Image Outlet in Collection View Cell
    @IBOutlet weak var imageInCollectionViewCell: UIImageView!
    
// Label Outlet in Collection View Cell
    @IBOutlet weak var lblInCollectionViewCell: UILabel!
    
// Outlet: Save Image Button
    @IBOutlet weak var SaveImageOutletInCollectionView: UIButton!

// Function called from cellForRowAt in Tableview Datasource method
        func setupData(obj:[String:Any],row:Int){
            lblInCollectionViewCell.text = obj["tags"]! as! String
            let strImgPath = obj["largeImageURL"]! as! String
            let urlPath = URL(string: strImgPath)
            imageInCollectionViewCell.kf.setImage(with: urlPath, placeholder: nil, options: nil) { [self] (result,err) in
            }
            SaveImageOutletInCollectionView.tag = row
        }
}
