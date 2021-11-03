import UIKit

// Pod - KingFisher Added
import Kingfisher

class ViewController: UIViewController {
    
// Counter variable created to store pageCount
    var counter = 1
    
// Variable to store query entered in PopUp Search
    var queryTyped = ""
    
// Array created to carry out filtering
    var originalStorage1 : [[String: Any]] = []
    
// Main Global Array to store all properties
    var filteredStorage : [[String: Any]] = []
    
// Outlet: Search Bar on Search Image Page
    @IBOutlet weak var mySearchBar: UISearchBar!

// Outlet: TblView on Search Image Page
    @IBOutlet weak var tblView: UITableView!

// Outlet: Search Icon on Top Left Corner
    @IBOutlet weak var SearchIconOnLeftCorner: UIBarButtonItem!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
// To hide Navigation Bar Bottom Border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
// Setting up tableview Delegate and Datasource
        tblView.delegate = self
        tblView.dataSource = self
    }
    
// Action called to save image file on resp. tableview cell
    @IBAction func saveImageAction(_ sender: UIButton) {
        print("tag->\(sender.tag)")
        let index = sender.tag
        let strImgPath = filteredStorage[index]["largeImageURL"]! as! String
        setCustomImage(strImgPath)
    }
    
// Function called from saveImageAction
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
    
// Action called when search Icon is Tapped on Left Corner
    @IBAction func ClickedOnSearchIcon(_ sender: Any) {
        let alert = UIAlertController(title: "Query PopUp", message: "Please enter a Query!", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter Query String."
            field.returnKeyType = .search
        }
        alert.addAction(UIAlertAction(title: "Show", style: .default, handler: { [self] _ in
            guard let fields = alert.textFields, fields.count == 1 else{
                return
            }
            let queryField = fields[0]
            guard let query = queryField.text?.trimmingCharacters(in: .whitespacesAndNewlines), queryField.text != " ", !query.isEmpty else{
                print("Invalid Entries")
                return
            }
            
// Assigning temp to queryTyped
            let temp = query.replacingOccurrences(of: " ", with: "+")
            queryTyped = temp
            self.view.endEditing(true)
            
// Initializing all variables to default
            originalStorage1 = []
            filteredStorage = []
            counter = 1
            
// Creating Api URL and Appending queryTyped parameter in it
            let url = "https://pixabay.com/api/?key=6535859-9848eef233ce93e8bfb33e5a6&q=\(queryTyped)&per_page=20&page=\(counter)"
            
// Function to start Api calling and getting response
            getData(from : url)
        }))
        present(alert, animated: true, completion: nil)
    }

// Function called from ClickedOnSearchIcon after creating api
    func getData(from url : String ){
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { [self]data, response, error in
            if error != nil {
                print(error?.localizedDescription as Any)
            }else {
                do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        if let postsData = json["hits"] as? [[String:Any]] {
                            self.originalStorage1.append(contentsOf: postsData)
                            self.filteredStorage.append(contentsOf: postsData)
                            DispatchQueue.main.async {
                                self.tblView.reloadData()
                            }
//                           print("\(postsData)")
//                            for post in 0..<(postsData.count-1){
//                                print(postsData[post]["tags"]!)
//                            print(postsData[post]["largeImageURL"]!)
//                            }
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }).resume()
    }
}

// Extension for adding padding in search textField
extension UITextField{
    func setPadding(){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

// Extension for TableView Delegate
extension ViewController: UITableViewDelegate{
    
// WillDisplay - For Pagination - fetch only 20 records
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == filteredStorage.count - 1 && mySearchBar.text == "" {
                moreData()
        }
    }
    
// MoreData will be called from willDisplay Delegate Function
    func moreData(){
    
// Increment pageCount / by updating counter
        counter += 1
        
// Recreate URL with new parameter values
        let url = "https://pixabay.com/api/?key=6535859-9848eef233ce93e8bfb33e5a6&q=\(queryTyped)&per_page=20&page=\(counter)"
        
// Function to start Api calling and getting response
        getData(from : url)
    }
}

// Extension for TableView Data Source
extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStorage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellInTableView
            let row = indexPath.row
            cell.layer.borderColor = CGColor(red: 236, green: 236, blue: 240, alpha: 0)
            cell.layer.borderWidth = 10
            cell.setupData(obj:filteredStorage[row],row:row)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "DetailsViewController") as? DetailsViewController
        vc?.labelOnDetailScreen = filteredStorage[indexPath.row]["tags"] as! String
        vc?.indexId = indexPath.row
        vc?.DetailsStorage = filteredStorage
        vc?.imgURL = filteredStorage[indexPath.row]["largeImageURL"]! as? String
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

// SearchBar to filter tableview cells
extension ViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       // print("\(searchText)")
        
        let arrSearchTexts = searchText.components(separatedBy: " ")
        
        filteredStorage = originalStorage1.filter { (obj) -> Bool in
            if let tags = obj["tags"] as? String{
                var hasTag = false
                for searchedTag in arrSearchTexts{
                    if tags.contains(searchedTag.lowercased()){
                        hasTag = true
                        break
                    }
                }
                return hasTag //tags.contains(searchText.lowercased())
            }
            return false
        }
        
        //Sorting data
        
        for i in 0..<filteredStorage.count {
                    var dict = filteredStorage[i]
                    dict["priority"] = 0
                    filteredStorage[i] = dict
                }
                
        for i in 0..<filteredStorage.count{
                    let tagInArr : String = filteredStorage[i]["tags"] as! String
                    var priorityInArr : Int = 0
                    for tagVal in arrSearchTexts{
                        if tagInArr.contains(tagVal){
                            priorityInArr += 1
                        }
                    }
                    filteredStorage[i]["priority"] = priorityInArr
                }
        
        filteredStorage.sort{
            ((($0 as Dictionary<String, AnyObject>)["priority"] as? Int)!) > ((($1 as Dictionary<String, AnyObject>)["priority"] as? Int)!)
        }
        
        if searchText == "" {
            filteredStorage = originalStorage1
        }
        
        tblView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
