//
//  ZZTriangleView.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/7/22.
//  Copyright © 2018 kingtang. All rights reserved.
//

import UIKit

class ZZTriangleView: ZZShapeView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInitView() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.backedLayer.path == nil {
            self.backedLayer.path = self.trianglePath().cgPath
        }
    }
    
    private func trianglePath() -> UIBezierPath {
        let height:CGFloat = self.frame.height
        let width:CGFloat = self.frame.width
        
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint.make(width, 0))
        path.addLine(to: CGPoint.make(width / 2, height))
        path.close()
        
        return path
    }
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    */
}
