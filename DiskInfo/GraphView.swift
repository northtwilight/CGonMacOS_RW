//
//  GraphView.swift
//  DiskInfo
//
//  Created by Massimo Savino on 2019-02-18.
//  Copyright © 2019 erndev. All rights reserved.
//

import Cocoa

@IBDesignable
class GraphView: NSView {
    
    // MARK: Properties
    
    var bytesFormatter = ByteCountFormatter()
    
    struct Constants {
        static let barHeight: CGFloat = 30.0
        static let barMinHeight: CGFloat = 20.0
        static let barMaxHeight: CGFloat = 40.0
        static let marginSize: CGFloat = 20.0
        static let pieChartWidthPercentage: CGFloat = 1.0 / 3.0
        static let pieChartBorderWidth: CGFloat = 1.0
        static let pieChartMinRadius: CGFloat = 30.0
        static let pieChartGradientAngle: CGFloat = 90.0
        static let barChartCornerRadius: CGFloat = 4.0
        static let barChartLegendSquareSize: CGFloat = 8.0
        static let legendTextMargin: CGFloat = 5.0
    }
    
    @IBInspectable var barHeight: CGFloat = Constants.barHeight {
        didSet {
            barHeight = max(min(barHeight, Constants.barMaxHeight), Constants.barMinHeight)
        }
    }
    
    @IBInspectable var pieChartUsedLineColor  : NSColor = NSColor.pieChartUsedStrokeColor
    @IBInspectable var pieChartAvailableLineColor  : NSColor = NSColor.pieChartAvailableStrokeColor
    @IBInspectable var pieChartAvailableFillColor  : NSColor = NSColor.pieChartAvailableFillColor
    @IBInspectable var pieChartGradientStartColor  : NSColor = NSColor.pieChartGradientStartColor
    @IBInspectable var pieChartGradientEndColor  : NSColor = NSColor.pieChartGradientEndColor
    @IBInspectable var barChartAvailableLineColor : NSColor = NSColor.availableStrokeColor
    @IBInspectable var barChartAvailableFillColor : NSColor = NSColor.availableFillColor
    @IBInspectable var barChartAppsLineColor : NSColor = NSColor.appsStrokeColor
    @IBInspectable var barChartAppsFillColor : NSColor = NSColor.appsFillColor
    @IBInspectable var barChartMoviesLineColor : NSColor = NSColor.moviesStrokeColor
    @IBInspectable var barChartMoviesFillColor : NSColor = NSColor.moviesFillColor
    @IBInspectable var barChartPhotosLineColor : NSColor = NSColor.photosStrokeColor
    @IBInspectable var barChartPhotosFillColor : NSColor = NSColor.photosFillColor
    @IBInspectable var barChartAudioLineColor : NSColor = NSColor.audioStrokeColor
    @IBInspectable var barChartAudioFillColor : NSColor = NSColor.audioFillColor
    @IBInspectable var barChartOthersLineColor : NSColor = NSColor.othersStrokeColor
    @IBInspectable var barChartOthersFillColor : NSColor = NSColor.othersFillColor
    
    
    var fileDistribution: FilesDistribution? {
        didSet {
            needsDisplay = true
        }
    }

    // MARK: Default methods
    
    func colorsForFileType(fileType: FileType) -> (strokeColor: NSColor, fillColor: NSColor) {
        switch fileType {
            case .audio(_, _): return (strokeColor: barChartAudioLineColor , fillColor: barChartAudioFillColor)
            case .movies(_, _): return (strokeColor: barChartMoviesLineColor , fillColor: barChartMoviesFillColor)
            case .photos(_, _): return (strokeColor: barChartPhotosLineColor , fillColor: barChartPhotosFillColor )
            case .apps(_, _): return (strokeColor: barChartAppsLineColor , fillColor: barChartAppsFillColor )
            case .other(_, _): return (strokeColor: barChartOthersLineColor , fillColor: barChartOthersFillColor )
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let context = NSGraphicsContext.current?.cgContext
        drawBarGraphInContext(context: context)
        drawPieChart()
    }
    
    override func prepareForInterfaceBuilder() {
        let used = Int64(100000000000)
        let available = used / 3
        let filesBytes = used / 5
        let distribution: [FileType] = [
            .apps(bytes: filesBytes / 2, percent: 0.1),
            .photos(bytes: filesBytes, percent: 0.2),
            .movies(bytes: filesBytes * 2, percent: 0.15),
            .audio(bytes: filesBytes, percent: 0.18),
            .other(bytes: filesBytes, percent: 0.2)
        ]
        fileDistribution = FilesDistribution(capacity: used + available,
                                            available: available,
                                            distribution: distribution)
    }
    
}
