//
//  ViewController.swift
//  MovieLabs
//
//  Created by Ricky Austin on 03/01/21.
//

import UIKit
import SDWebImage

enum DownloadState{
    case new, downloaded, failed
}

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let v = UITableView()
        v.delegate = self
        v.dataSource = self
        v.rowHeight = 150
        v.translatesAutoresizingMaskIntoConstraints = false
        v.register(UITableViewCell.self, forCellReuseIdentifier: "movie-cell")
        v.tableFooterView = UIView()
        return v
    }()
    
    
    private var photos = [Photos]()
    let getUnsplash = Unsplash()
    var addPage = 1
    
    fileprivate var activityIndicator: LoadMoreActivityIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        activityIndicator = LoadMoreActivityIndicator(scrollView: tableView, spacingFromLastCell: 10, spacingFromLastCellWhenLoadMoreActionStart: 60)
        callApi()
        
    }
    
    
    func callApi(){
        getUnsplash.getData(page: addPage){[self] results, errorMessage in
            if let results = results{
                photos.append(contentsOf: results)
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
    }
    
    
    
}

extension ViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        activityIndicator.start {
            DispatchQueue.global(qos: .utility).async { [self] in
                self.addPage += 1
                self.callApi()
                sleep(3)
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stop()
                }
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movie-cell", for: indexPath)
        let photo = photos[indexPath.row]
        
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = photo.color
        // print(photo.urlLinks.thumb)
        print("INDEX \(indexPath.row) : \(photo.state) \(photos.count)")
        
        if cell.accessoryView == nil {
            cell.accessoryView = UIActivityIndicatorView(style: .medium)
        }
        
        guard let indicator = cell.accessoryView as? UIActivityIndicatorView else { fatalError() }
        view.addSubview(indicator)
        
        cell.imageView!.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        cell.imageView!.sd_setImage(with: URL(string: photo.urlLinks.regular), placeholderImage: UIImage(named: "placeholder"))
        return cell
    }
    
    
}

