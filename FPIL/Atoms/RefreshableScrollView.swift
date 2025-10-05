//
//  RefreshableScrollView.swift
//  FPIL
//
//  Created by OrganicFarmers on 22/09/25.
//

import Foundation
import SwiftUI

struct RefreshableScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    let onRefresh: () async -> Void
    
    init(@ViewBuilder content: () -> Content, onRefresh: @escaping () async -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .gray // 👈 make spinner gray
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh), for: .valueChanged)
        
        scrollView.refreshControl = refreshControl
        
        let hosting = UIHostingController(rootView: content)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        scrollView.addSubview(hosting.view)
        scrollView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hosting.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        context.coordinator.hostingController = hosting
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onRefresh: onRefresh)
    }
    
    class Coordinator: NSObject {
        var onRefresh: () async -> Void
        weak var hostingController: UIHostingController<Content>?
        
        init(onRefresh: @escaping () async -> Void) {
            self.onRefresh = onRefresh
        }
        
        @objc func handleRefresh(_ sender: UIRefreshControl) {
            Task {
                await onRefresh()
                await sender.endRefreshing()
            }
        }
    }
}
