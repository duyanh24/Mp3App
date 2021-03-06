//
//  MypageViewController.swift
//  Mp3App
//
//  Created by AnhLD on 9/29/20.
//  Copyright © 2020 AnhLD. All rights reserved.
//

import RxSwift
import RxCocoa
import Reusable
import UIKit
import RxDataSources

class MypageViewController: BaseViewController, StoryboardBased, ViewModelBased {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loginContainer: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    var viewModel: MypageViewModel!
    private let disposeBag = DisposeBag()
    private let loadDataTrigger = PublishSubject<Void>()
    private let deletePlaylistTrigger = PublishSubject<String>()
    
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<MypageSectionModel> = RxTableViewSectionedReloadDataSource(configureCell: { [weak self] (dataSource, tableView, indexPath, item) -> UITableViewCell in
        guard let self = self else { return UITableViewCell() }
        switch dataSource[indexPath] {
        case .favourite(let type, let libraryTitle):
            let cell = tableView.dequeueReusableCell(for: indexPath) as LibraryTableViewCell
            let libraryTableViewCellViewModel = LibraryTableViewCellViewModel(libraryTitle: libraryTitle)
            cell.configureCell(viewModel: libraryTableViewCellViewModel)
            return cell
        case .playlist(let type, let playlist):
            let cell = tableView.dequeueReusableCell(for: indexPath) as PlaylistTableViewCell
            let playlistTableViewCellViewModel = PlaylistTableViewCellViewModel(playlist: playlist)
            cell.configureCell(viewModel: playlistTableViewCellViewModel)
            return cell
        }
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepareUI() {
        super.prepareUI()
        setupTableView()
        loginButton.layer.cornerRadius = 5
    }
    
    private func bindViewModel() {
        let input = MypageViewModel.Input(loadDataTrigger: loadDataTrigger, deletePlaylist: deletePlaylistTrigger)
        let output = viewModel.transform(input: input)
        output.mypageDataModel
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let self = self else {
                return
            }
            switch self.dataSource[indexPath] {
            case .favourite:
                SceneCoordinator.shared.transition(to: Scene.libraryDetail)
            case .playlist(_, let playlistName):
                SceneCoordinator.shared.transition(to: Scene.playlistDetail(playlistName: playlistName))
            }
        }).disposed(by: disposeBag)
        
        output.deletePlaylistResult.subscribe(onNext: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription, completion: nil)
            case .success:
                break
            }
        })
        .disposed(by: disposeBag)
        
        output.checkLogin.subscribe(onNext: { [weak self] isLoggedIn in
            self?.loginContainer.isHidden = isLoggedIn
            self?.tableView.isHidden = !isLoggedIn
        })
        .disposed(by: disposeBag)
        
        loginButton.rx.tap.subscribe(onNext: { _ in
            SceneCoordinator.shared.transition(to: Scene.login)
        })
        .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        tableView.addGestureRecognizer(setupGesture())
        tableView.delegate = self
        tableView.register(cellType: LibraryTableViewCell.self)
        tableView.register(cellType: PlaylistTableViewCell.self)
        tableView.contentInset.bottom = 50
    }
}

extension MypageViewController {
    func loadData() {
        loadDataTrigger.onNext(())
    }
}

extension MypageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch dataSource[section] {
        case .favourite:
            return .leastNonzeroMagnitude
        case .playlist:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = MypageCellHeaderView()
        switch dataSource[section] {
        case .favourite:
            view.setTitle(title: Strings.library)
        case .playlist:
            view.setTitle(title: Strings.playlist)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch dataSource[section] {
        case .favourite:
            return nil
        case .playlist:
            let playlistCellFooterView = PlaylistCellFooterView()
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapFooter))
            playlistCellFooterView.addGestureRecognizer(tapRecognizer)
            return playlistCellFooterView
        }
    }
    
    @objc func handleTapFooter(gestureRecognizer: UIGestureRecognizer) {
        SceneCoordinator.shared.transition(to: Scene.createPlaylist)
    }
}

extension MypageViewController: UIGestureRecognizerDelegate {
    func setupGesture() -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        return longPress
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                switch dataSource[indexPath] {
                case .favourite:
                    return
                case .playlist(let playlistSectionModel):
                    showConfirmMessage(title: playlistSectionModel.playlist, message: Strings.deletePlaylistMessage, confirmTitle: Strings.confirm, cancelTitle: Strings.cancel) { [weak self] selectedCase in
                        if selectedCase == .confirm {
                            self?.deletePlaylistTrigger.onNext(playlistSectionModel.playlist)
                        }
                    }
                }
            }
        }
    }
}
