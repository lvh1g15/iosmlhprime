//
//  firsttabViewController.swift
//  teenbudget
//
//  Created by landon vago-hughes on 01/04/2017.
//  Copyright © 2017 landon vago-hughes. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

func ==(lhs: Circle, rhs: Circle) -> Bool {
    return lhs.budget == rhs.budget
    
    //conforming to equatable
    
}

class Circle: Hashable, Equatable {
    var circle: UIView?
    var textView: UITextField?
    var budget: Double?
    var category: UILabel?
    var payment: String?
    
    var hashValue: Int{
        return Int(self.budget!)
    }

    
    init(circle: UIView, textView: UITextField, budget: Double, category: UILabel, payment: String) {
        self.circle = circle
        self.textView = textView
        self.budget = budget
        self.category = category
        self.payment = payment
        
    }
}

var initialisingPayment: String! = "\(0)"
var bubbly: [Bubble] = []
var circles: [Circle] = []

class firsttabViewController: UIViewController, UITextFieldDelegate {
    
    var ref: FIRDatabaseReference?
    var refhandle: UInt = 0
    
    var circleCenter: CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if FIRAuth.auth()?.currentUser != nil {
        
            Fetch.dispatchQueue { (bubbles) in
                
                
                bubbly.append(bubbles)
                print(bubbles)
                
                
                let newArray = self.uniqueElementsFrom(array: bubbly)
                
                for i in newArray {
                    
                    var z: Double
                    var x: Double
                    var fontsize: Double
                    let titleWidth: CGFloat = 50
                    let titleHeight: CGFloat = 50
                    let labelWidth: CGFloat = 50
                    let labelHeight: CGFloat = 50
                    
                    let bubbleMax: Double = 100
                    
                    z = Double(i.payment)!/Double(i.budget)*bubbleMax + 20.0
                    fontsize = z/10.0
                    
                    let circle = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0+z, height: 50.0+z))
                    
                    x = (73*(z+60))/160
                    circle.layer.cornerRadius = CGFloat(x)
                    
                    
                    circle.backgroundColor = UIColor.blue
                    
                    let label = UITextField(frame: CGRect(x: circle.center.x-titleWidth/2, y: circle.center.y, width: circle.center.x+30, height: labelHeight))
                    let title = UILabel(frame: CGRect(x: circle.center.x-titleWidth/2, y: circle.center.y/3, width: circle.center.x+30, height: titleHeight))
                    
                    print(circle.center.x)
                    
                    title.text = i.category
                    title.font = UIFont(name: "HelveticaNeue-UltraLight", size: CGFloat(Double(z/2)))
//                    title.sizeThatFits(CGSize(dictionaryRepresentation: z as! CFDictionary)!)
                    label.text = i.payment
                    label.font = UIFont(name: "HelveticaNeue-UltraLight", size: CGFloat(Double(z/2)))
                    
                    label.textColor = .white
                    title.textColor = .white
                    
                    circle.addSubview(label)
                    circle.addSubview(title)
                    
                    circle.center = self.view.center
                    
                    
                    label.delegate = self
                
                    let acircle = Circle.init(circle: circle, textView: label, budget: i.budget, category: title, payment: i.payment)
                    circles.append(acircle)
                    let circleArray = self.uniqueCircle(array: circles)

                    for i in circleArray {
                        
                    self.view.addSubview(i.circle!)
                    i.circle!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.dragCircle)))
                    }
                }
                
            }

        } else {
            self.performSegue(withIdentifier: "mainToLogin", sender: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        for i in circles {
            if textField == i.textView {
                findActiveTextField(subviews: [i.circle!], textField: &i.textView)
                let changedPayment = textField.text
                let category = i.category!.text!
                
                if textField.text != "" {
                    
                    let uid = FIRAuth.auth()?.currentUser?.uid
                    
                    let ref = FIRDatabase.database().reference(fromURL: "https://teenbudget-75e27.firebaseio.com/")
                    
                    ref.child("users").child(uid!).child(category).updateChildValues(["payment": changedPayment!])
                    
                    dismiss(animated: true, completion: nil)
                    
                }
            }
        }
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uniqueElementsFrom(array: [Bubble]) -> [Bubble] {
        var set = Set<Bubble>()
        let result = array.filter {
            guard !set.contains($0) else {
                return false
            }
            set.insert($0)
            return true
        }
        return result
    }
    
    func uniqueCircle(array: [Circle]) -> [Circle] {
        var set = Set<Circle>()
        let result = array.filter {
            guard !set.contains($0) else {
                return false
            }
            set.insert($0)
            return true
        }
        return result
    }
    
    func findActiveTextField(subviews : [UIView], textField : inout UITextField?) {

        guard textField == nil else { return }
        
        for view in subviews {
            if let tf = view as? UITextField, view.isFirstResponder {
                textField = tf
                break
            }
            else if !view.subviews.isEmpty {
                findActiveTextField (subviews: view.subviews, textField: &textField)
            }
        }
    }

    func dragCircle(gesture: UIPanGestureRecognizer) {
        let target = gesture.view!
        
        switch gesture.state {
        case .began, .ended:
            circleCenter = target.center
        case .changed:
            let translation = gesture.translation(in: self.view)
            target.center = CGPoint(x: circleCenter!.x + translation.x, y: circleCenter!.y + translation.y)
        default: break
        }
    }
    
}
