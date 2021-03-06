//
//  CoursesViewController.swift
//  Nerdfeed
//
//  Created by Akshay Hegde on 7/2/14.
//  Copyright (c) 2014 Akshay Hegde. All rights reserved.
//

import UIKit

class CoursesViewController: UITableViewController, NSURLSessionDataDelegate {

    var session: NSURLSession?
    var courses: NSArray
    var webViewController: WebViewController?

    convenience init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        self.init(nibName: nil, bundle: nil)
    }

    override convenience init(style: UITableViewStyle) {
        self.init(nibName: nil, bundle: nil)

        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        navigationItem.title = "Courses"
        courses = []
        fetchFeed()
    }

    required init(coder aDecoder: NSCoder) {
        courses = []
        super.init(coder: aDecoder)
    }

    func fetchFeed() {
        if session != nil {
            // the secure url given in the book is actually https://bookapi.bignerdranch.com/private/courses.json
            // but that doesn't seem to work :|
            let requestString = "https://bookapi.bignerdranch.com/private/courses.json"
            let url = NSURL(string: requestString)
            let request = NSURLRequest(URL: url!)
            let dataTask = session!.dataTaskWithRequest(request) {
                (data, _, _) in
                let jsonObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if jsonObject != nil {
                    self.courses = jsonObject!["courses"] as! [[String: String]]
                }

                println(self.courses)

                // Reload table view data on the main thread
                dispatch_async(dispatch_get_main_queue()) { self.tableView.reloadData() }
            }
            dataTask.resume()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        // Load the custom table view cell
        tableView.registerNib(nib, forCellReuseIdentifier: "CustomTableViewCell")
    }

    // MARK: UITableViewController methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("CustomTableViewCell",
                forIndexPath: indexPath) as! CustomTableViewCell
            let course = courses[indexPath.row] as! NSDictionary
            let courseTitle = course["title"] as! String

            // Try to find the next start date for the course (Chapter 21 Gold Challenge)
            let upcomingTimes = (course["upcoming"] as! NSArray).objectAtIndex(0) as! NSDictionary
            let startDate = upcomingTimes["start_date"] as! String

            cell.titleLabel!.text = courseTitle
            cell.upcomingLabel!.text = "Upcoming on: \(startDate)"

            return cell
    }

    override func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let course = courses[indexPath.row] as! Dictionary<String, String>
        let url = NSURL(string: course["url"]!)

        webViewController!.title = course["title"]
        webViewController!.URL = url
        if splitViewController == nil {
            navigationController?.pushViewController(webViewController!, animated: true)
        }
    }

    // NSURLSessionDataDelegate methods
    func URLSession(session: NSURLSession,
        didReceiveChallenge challenge: NSURLAuthenticationChallenge,
        completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void)
    {
        let cred = NSURLCredential(user: "BigNerdRanch",
            password: "AchieveNerdvana", persistence: .ForSession)
        completionHandler(.UseCredential, cred)
    }
}
