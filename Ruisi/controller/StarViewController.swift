//
//  StarViewController.swift
//  Ruisi
//
//  Created by yang on 2017/6/28.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit
import Kanna

// 我的收藏页面
class StarViewController: BaseTableViewController<StarData> {
    
    override func viewDidLoad() {
        self.autoRowHeight = false
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func getUrl(page: Int) -> String {
        return Urls.starUrl + "&page=\(page)"
    }
    
    override func parseData(pos: Int, doc: HTMLDocument) -> [StarData] {
        var subDatas: [StarData] = []
        loop1:
            for li in doc.xpath("/html/body/div[1]/ul/li") {
                let a = li.css("a").first
                var tid: Int?
                if let u = a?["href"] {
                    tid = Utils.getNum(from: u)
                } else {
                    continue
                } //没有tid和咸鱼有什么区别
                
                for d in self.datas {
                    if d.tid == tid {
                        break loop1
                    }
                }
                
                let title = a?.text?.trimmingCharacters(in: CharacterSet(charactersIn: "\r\n "))
                let color = Utils.getHtmlColor(from: a?["style"])
                let d = StarData(title: title ?? "未获取到标题", tid: tid!, titleColor: color)
                d.rowHeight = caculateRowheight(width: self.tableViewWidth, title: d.title)
                subDatas.append(d)
        }
        if subDatas.count < 20 {
            self.totalPage = self.currentPage
        }
        return subDatas
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let d = datas[indexPath.row]
        
        titleLabel.text = d.title
        if let color = d.titleColor {
            titleLabel.textColor = color
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteStarAlert(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let d = datas[indexPath.row]
        return d.rowHeight
    }
    
    // 计算行高
    private func caculateRowheight(width: CGFloat, title: String) -> CGFloat {
        let titleHeight = title.height(for: width - 32, font: UIFont.systemFont(ofSize: 16, weight: .medium))
        // 上间距(12) + 正文(计算) + 下间距(16)
        return 16 + titleHeight + 16
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        _ = super.numberOfSections(in: tableView)
        if datas.count == 0 && !isLoading {//no data avaliable
            let title = "暂无收藏"
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
            label.text = title
            label.textColor = UIColor.darkGray
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = UIColor.lightGray
            label.sizeToFit()
            
            tableView.backgroundView = label
            tableView.separatorStyle = .none
            
            return 0
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
            return 1
        }
    }
    
    func showDeleteStarAlert(indexPath: IndexPath) {
        let title = datas[indexPath.row].title
        let _ = datas[indexPath.row].tid
        let alert = UIAlertController(title: "删除收藏", message: "取消收藏【\(title)】?吗?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消收藏(暂不支持)", style: .destructive, handler: { (action) in
            // TODO
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? PostViewController,
            let cell = sender as? UITableViewCell {
            let index = tableView.indexPath(for: cell)!
            dest.title = datas[index.row].title
            dest.tid = datas[index.row].tid
        }
    }
}
