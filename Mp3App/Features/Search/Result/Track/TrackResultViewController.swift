//
//  TrackResultViewController.swift
//  Mp3App
//
//  Created by AnhLD on 11/3/20.
//  Copyright © 2020 AnhLD. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import RxDataSources
import XLPagerTabStrip

class TrackResultViewController: BaseResultViewController, StoryboardBased, ViewModelBased, IndicatorInfoProvider {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notificationLabel: UILabel!
    
    var viewModel: TrackResultViewModel!
    private let disposeBag = DisposeBag()
    private let keywordTrigger = BehaviorSubject<String>(value: "")
    private let loadMoreTrigger = PublishSubject<Void>()
    private var isLoadMoreEnabled = true
    private let startLoadingOffset = CGFloat(20.0)
    let loading = PublishSubject<Bool>()
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<TrackSectionModel>(
        configureCell: { _, tableView, indexPath, track in
            let cell = tableView.dequeueReusableCell(for: indexPath) as TrackResultCell
            let trackResultCellViewModel = TrackResultCellViewModel(track: track)
            cell.configureCell(viewModel: trackResultCellViewModel)
            return cell
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    override func prepareUI() {
        super.prepareUI()
        setupTableView()
        notificationLabel.isHidden = true
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: Strings.track)
    }
    
    override func search(keyword: String) {
        keywordTrigger.onNext(keyword)
    }
    
    private func bindViewModel() {
        let input = TrackResultViewModel.Input(searchTrack: keywordTrigger,
                                               loadMore: loadMoreTrigger,
                                               play: tableView.rx.modelSelected(Track.self).asObservable())
        let output = viewModel.transform(input: input)
        
        output.activityIndicator.bind(to: loading).disposed(by: disposeBag)
        output.loadData.subscribe().disposed(by: disposeBag)
        output.loadMoreData.subscribe().disposed(by: disposeBag)
        output.isLoadMoreEnabled.subscribe(onNext: { [weak self] isLoadMoreEnabled in
            self?.isLoadMoreEnabled = isLoadMoreEnabled
        })
        .disposed(by: disposeBag)
        
        output.playTrack.subscribe().disposed(by: disposeBag)
        
        output.dataSource.skip(1)
            .do(onNext: { [weak self] data in
                guard let isEmpty = data.first?.items.isEmpty else {
                    self?.notificationLabel.isHidden = false
                    return
                }
                self?.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                self?.notificationLabel.isHidden = !isEmpty
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset.subscribe(onNext: { [weak self] contentOffset in
            self?.loadMore(contentOffset: contentOffset)
        }).disposed(by: disposeBag)
    }
    
    private func loadMore(contentOffset: CGPoint) {
        if contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height && isLoadMoreEnabled {
            loadMoreTrigger.onNext(())
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.register(cellType: TrackResultCell.self)
        tableView.contentInset.bottom = 50
        tableView.keyboardDismissMode = .onDrag
    }
}

extension TrackResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
