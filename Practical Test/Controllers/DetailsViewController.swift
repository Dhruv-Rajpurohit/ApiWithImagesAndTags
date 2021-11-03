import UIKit

// Pod - ISVImageScrollView Added
import ISVImageScrollView

class DetailsViewController: UIViewController, UIScrollViewDelegate {
    
// Main Global Array to store all properties
    var DetailsStorage : [[String: Any]] = []
    
// Third Party ScrollView Added for Zooming - ISVImageScrollView
    @IBOutlet weak var imageScrollView: ISVImageScrollView!

// Outlet: ImagView on DetailsViewController
    @IBOutlet weak var imgViewOnDetailsScreen: UIImageView!
    
// Outlet: Label on DetailsVIewController
    @IBOutlet weak var lblOnDetailsScreen: UILabel!

// Outlet: To Save Image to Photo Lib
    @IBOutlet weak var SaveImageBtn: UIButton!

// Outlet: RightArrow Button
    @IBOutlet weak var RightButtonOutlet: UIButton!
    
// Outlet: LeftArrow Button
    @IBOutlet weak var LeftButtonOutlet: UIButton!
    
    var imgURL:String? = nil
    var labelOnDetailScreen = ""
    var indexId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(imgURL)")
        print("\(labelOnDetailScreen)")
        
        lblOnDetailsScreen.text = labelOnDetailScreen
        let urlPath = URL(string: imgURL ?? "")
        imgViewOnDetailsScreen.kf.setImage(with: urlPath, placeholder: nil, options: nil) { (result,err) in
        }
        
        self.imageScrollView.imageView = self.imgViewOnDetailsScreen
        self.imageScrollView.maximumZoomScale = 6.0
        self.imageScrollView.delegate = self
    }
    
// Right Arrow Clicked on Screen
    @IBAction func RightArrowClicked(_ sender: Any) {
        if indexId < DetailsStorage.count - 1 {
            indexId = indexId + 1
            lblOnDetailsScreen.text = DetailsStorage[indexId]["tags"] as? String
            let imgChange = DetailsStorage[indexId]["largeImageURL"]
            let urlPath = URL(string: imgChange as! String)
            imgViewOnDetailsScreen.kf.setImage(with: urlPath, placeholder: nil, options: nil) { (result,err) in
            }
        }
    }
    
// Left Arrow Clicked on Screen
    @IBAction func LeftArrowClicked(_ sender: Any) {
        if  indexId > 0{
            indexId = indexId - 1
            lblOnDetailsScreen.text = DetailsStorage[indexId]["tags"] as? String
            let imgChange = DetailsStorage[indexId]["largeImageURL"]
            let urlPath = URL(string: imgChange as! String)
            imgViewOnDetailsScreen.kf.setImage(with: urlPath, placeholder: nil, options: nil) { (result,err) in
            }
        }
    }
    
// Zoom In and Out Of Images - UiScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgViewOnDetailsScreen
    }
    
// Objc method calling on save image button tap
    @IBAction func SaveImageFunctionCalled(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(imgViewOnDetailsScreen.image!, self, #selector(image(_: didFinishSavingWithError: contextInfo:)), nil)
    }
    
// Action: Back Button Pressed
    @IBAction func BackButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
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
}

