//
//  ZZTriangleView.swift
//  HealthTaiZhou
//
//  Created by mac on 2018/7/22.
//  Copyright © 2018 kingtang. All rights reserved.
//

import UIKit

public class ZZTriangleView: ZZShapeView {
    /// 确认三角行的3个点，顺时针
    public var points: [CGPoint] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func commonInitView() {

    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard self.points.count >= 3 else {
            return
        }

        if self.backedLayer.path == nil {
            self.backedLayer.path = self.trianglePath().cgPath
        }
    }

    private func trianglePath() -> UIBezierPath {

        let path = UIBezierPath()
        path.move(to: points[0].scaled(to: bounds.size))
        path.addLine(to: points[1].scaled(to: bounds.size))
        path.addLine(to: points[2].scaled(to: bounds.size))
        path.close()

        return path
    }
}
