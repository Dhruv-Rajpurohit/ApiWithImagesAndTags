import UIKit

class CellInTableView: UITableViewCell {

// Outlet: ImageView in TableViewCell
    @IBOutlet weak var ImageViewInsideTableCell: UIImageView!
    
// Outlet: Label in TableViewCell
    @IBOutlet weak var labelInTableCell: UILabel!
    
// Outlet: SaveButton in TableViewCell
    @IBOutlet weak var SaveImageButtonInTableCell: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
// Function called from cellForRowAt in Tableview Datasource method
    func setupData(obj:[String:Any],row:Int){
        labelInTableCell.text = obj["tags"]! as! String
        let strImgPath = obj["largeImageURL"]! as! String
        let urlPath = URL(string: strImgPath)
        ImageViewInsideTableCell.kf.setImage(with: urlPath, placeholder: nil, options: nil) { [self] (result,err) in
        }
        SaveImageButtonInTableCell.tag = row
    }
}
