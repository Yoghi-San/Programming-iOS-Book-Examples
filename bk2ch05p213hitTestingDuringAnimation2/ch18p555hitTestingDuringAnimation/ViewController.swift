

import UIKit

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}
extension CGSize {
    init(_ width:CGFloat, _ height:CGFloat) {
        self.init(width:width, height:height)
    }
}
extension CGPoint {
    init(_ x:CGFloat, _ y:CGFloat) {
        self.init(x:x, y:y)
    }
}
extension CGVector {
    init (_ dx:CGFloat, _ dy:CGFloat) {
        self.init(dx:dx, dy:dy)
    }
}



class ViewController : UIViewController {
    @IBOutlet var button : UIButton!
    
    var oldButtonCenter : CGPoint!
    var anim : UIViewPropertyAnimator!
    let goal = CGPoint(100,400)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.oldButtonCenter = self.button.center // so we can test repeatedly
        
        self.configAnimator()
        
        let p = UIPanGestureRecognizer(target: self, action: #selector(pan))
        self.button.addGestureRecognizer(p)
    }
    
    func configAnimator() {
        self.anim = UIViewPropertyAnimator(duration: 10, curve: .linear) {}
        anim.addAnimations {
            self.button.center = self.goal
        }
    }
    
    @IBAction func tapme(_ sender: Any?) {
        print("tap! (the button's action method)")
    }
    
    @IBAction func start(_ sender: Any?) {
        print("you tapped Start")
        if anim.state == .active {
            anim.stopAnimation(false)
            anim.finishAnimation(at: .current)
        }
        self.button.center = self.oldButtonCenter
        self.configAnimator()
        anim.startAnimation()
    }
    
    func pan(_ p: UIPanGestureRecognizer) {
        let v = p.view!
        switch p.state {
        case .began:
            if anim == nil || anim.state == .inactive {
                self.configAnimator()
            }
            if anim.state == .active {
                anim.stopAnimation(true)
            }
            fallthrough
        case .changed:
            // normal draggability
            let delta = p.translation(in:v.superview)
            var c = v.center
            c.x += delta.x; c.y += delta.y
            v.center = c
            p.setTranslation(.zero, in: v.superview)
        case .ended:
            // how far are we from the goal relative to original distance?
            func pyth(_ pt1:CGPoint, _ pt2:CGPoint) -> CGFloat {
                let x = pt1.x - pt2.x
                let y = pt1.y - pt2.y
                return sqrt(x*x + y*y)
            }
            let origd = pyth(self.oldButtonCenter, self.goal)
            let curd = pyth(v.center, self.goal)
            let factor = curd/origd
            anim.addAnimations {
                self.button.center = self.goal
            }
            anim.startAnimation()
            anim.pauseAnimation()
            anim.continueAnimation(withTimingParameters: anim.timingParameters, durationFactor: factor)
        default: break
        }
    }
}
