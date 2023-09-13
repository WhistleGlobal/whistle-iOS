//
//  SearchBar.swift
//  Whistle
//
//  Created by 박상원 on 2023/09/13.
//

import SwiftUI
import UIKit

// MARK: - SearchBarViewController

class SearchBarViewController<Content: View>: UIViewController {
  let searchController: UISearchController
  let contentViewController: UIHostingController<Content>

  init(searchController: UISearchController, withContent content: Content) {
    contentViewController = UIHostingController(rootView: content)
    self.searchController = searchController

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)

    guard
      let parent,
      parent.navigationItem.searchController == nil
    else {
      return
    }
    parent.navigationItem.searchController = searchController
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(contentViewController.view)
    contentViewController.view.frame = view.bounds
  }
}

// MARK: - SearchBar

struct SearchBar<Content: View>: UIViewControllerRepresentable {
  typealias UIViewControllerType = SearchBarViewController<Content>

  @Binding var text: String
  @ViewBuilder var content: () -> Content

  class Coordinator: NSObject, UISearchResultsUpdating {
    @Binding var text: String

    init(text: Binding<String>) {
      _text = text
    }

    func updateSearchResults(for searchController: UISearchController) {
      if text != searchController.searchBar.text {
        text = searchController.searchBar.text ?? ""
      }
    }
  }

  func makeCoordinator() -> SearchBar.Coordinator {
    Coordinator(text: $text)
  }

  func makeUIViewController(context: UIViewControllerRepresentableContext<SearchBar>) -> UIViewControllerType {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = context.coordinator

    return SearchBarViewController(searchController: searchController, withContent: content())
  }

  func updateUIViewController(
    _ uiViewController: UIViewControllerType,
    context _: UIViewControllerRepresentableContext<SearchBar>)
  {
    let contentViewController = uiViewController.contentViewController

    contentViewController.view.removeFromSuperview()
    contentViewController.rootView = content()
    uiViewController.view.addSubview(contentViewController.view)
    contentViewController.view.frame = uiViewController.view.bounds
  }
}
