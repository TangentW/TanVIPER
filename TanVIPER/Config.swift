//
//  Config.swift
//  TanVIPER
//
//  Created by Tan on 2016/12/6.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit

//  MARK: - Protocol
protocol Request { }

protocol Response { }

protocol ViewModel { }


protocol ViewToInteratorPipline {
    func refresh(request: Request)
}

protocol InteratorToPresenterPipline {
    func present(response: Response)
}

protocol PresenterToViewPipline {
    func display(viewModel: ViewModel)
}

//  MARK: - Abstract Class
class View: ViewController, PresenterToViewPipline {
    
    final let interator: Interactor
    
    required init(interator: Interactor) {
        self.interator = interator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func display(viewModel: ViewModel) {
        fatalError("display(viewModel:) is an abstract function")
    }
    
    func show(router: Router, userInfo: Any?) {
        fatalError("show(route:userInfo:) is an abstract function")
    }
}

class Interactor: ViewToInteratorPipline {
    
    final let presenter: Presenter
    
    required init(presenter: Presenter) {
        self.presenter = presenter
    }
    
    func refresh(request: Request) {
        fatalError("refresh(request:) is an abstract function")
    }
}

class Presenter: InteratorToPresenterPipline {
    
    private final weak var _view: View? {  //  !! Weak !!
        didSet {
            self._router = Router(presenter: self)
        }
    }
    
    private final var _router: Router?
    
    final var view: View? {
        set {
            assert(self._view == nil, "view has already set!")
            self._view = newValue
        }
        
        get {
            return self._view
        }
    }
    
    final var router: Router? {
        get {
            return self._router
        }
    }
    
    required init() { }
    
    func present(response: Response) {
        fatalError("response(Response:) is an abstract function")
    }
}

//  MARK: - Unity
struct Unity {
    let viewType: View.Type
    let interatorType: Interactor.Type
    let presenterType: Presenter.Type
}

extension Unity: ExpressibleByArrayLiteral {
    
    typealias Element = AnyClass
    
    init(arrayLiteral elements: Unity.Element...) {
        assert(elements.count == 3)
        guard let viewType = elements[0] as? View.Type else { assert(false) }
        guard let interactorType = elements[1] as? Interactor.Type else { assert(false) }
        guard let presenterType = elements[2] as? Presenter.Type else { assert(false) }
        self.viewType = viewType
        self.interatorType = interactorType
        self.presenterType = presenterType
    }
}

//  MARK: - Binder
class Binder {
    
    static var unitySet: [String: Unity] = [:]
    
    static func addUnity(_ unity: Unity, identifier: String) {
        self.unitySet[identifier] = unity
    }
    
    static func obtainView(identifier: String) -> View? {
        guard let unity = self.unitySet[identifier] else { return nil }
        
        //  Bind
        let presenter = unity.presenterType.init()
        let interator = unity.interatorType.init(presenter: presenter)
        let view = unity.viewType.init(interator: interator)
        presenter.view = view
        return view
    }
    
}

//  MARK: - Router
enum RouteType {
    case root(identifier: String)
    case push(identifier: String)
    case modal(identifier: String)
    case back
}

extension RouteType {
    var identifier: String? {
        switch self {
        case let .root(identifier):
            return identifier
        case let .push(identifier):
            return identifier
        case let .modal(identifier):
            return identifier
        default:
            return nil
        }
    }
    
    var view: View? {
        guard let identifier = self.identifier else { return nil}
        return Binder.obtainView(identifier: identifier)
    }
}

class Router {
    
    let presenter: Presenter?
    
    required init(presenter: Presenter? = nil) {
        self.presenter = presenter
    }
    
    func route(type: RouteType, userInfo: Any?) {
        let view = type.view
        view?.show(router: self, userInfo: userInfo)
        switch type {
        case .root:
            UIApplication.shared.keyWindow?.rootViewController = view
        case .push:
            if let view = view { self.presenter?.view?.navigationController?.pushViewController(view, animated: true) }
        case .modal:
            if let view = view { self.presenter?.view?.present(view, animated: true, completion: nil) }
        case .back:
            guard let view = presenter?.view else { return }
            if view.presentationController != nil {
                view.dismiss(animated: true, completion: nil)
            } else {
                _ = view.navigationController?.popViewController(animated: true)
            }
        }
    }
}

