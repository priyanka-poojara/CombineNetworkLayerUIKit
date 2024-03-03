//
//  Network+Delegate.swift
//  NetworkCall
//
//  Created by Priyanka on 02/09/23.
//

import Foundation

/// This Delegate will be thrown for the every fraction in Double of every packet sent or received.
/// - can be easily used to show the proggress of long task
public protocol PNetworkServicesDelegate : AnyObject {
    func didProggressed(_ ProgressDone : Double)
}
