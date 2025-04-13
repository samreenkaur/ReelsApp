// ReelsViewController.swift
import UIKit
import AVFoundation

class ReelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var tableView = UITableView()
    let viewModel = ReelsViewModel()
    var currentPlayingCell: ReelsCell?
    var isMuted: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        viewModel.loadInitialReels { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.playVideoAt(index: 0)
            }
        }
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.register(ReelsCell.self, forCellReuseIdentifier: "ReelsCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isPagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = nil
        tableView.rowHeight = UIScreen.main.bounds.height
    }

    func playVideoAt(index: Int) {
        guard index < viewModel.reels.count else { return }
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ReelsCell {
            currentPlayingCell?.pause()
            currentPlayingCell = cell
            cell.play(isMuted: isMuted)
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReelsCell", for: indexPath) as? ReelsCell else {
            return UITableViewCell()
        }
        let reel = viewModel.reels[indexPath.row]
        cell.configure(with: reel, isMuted: isMuted)

        cell.onMuteTapped = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.isMuted.toggle()
            cell.player?.volume = self.isMuted ? 0 : 1
            cell.muteButton.setTitle(self.isMuted ? "Unmute" : "Mute", for: .normal)
        }
        
        cell.onLikeTapped = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.viewModel.toggleLike(for: indexPath.row)
            cell.likeButton.setTitle(!self.viewModel.reels[indexPath.row].isLiked ? "Dislike" : "Like", for: .normal)

        }

        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.y / scrollView.frame.height))
        playVideoAt(index: index)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentPlayingCell?.pause()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight * 2 {
            // Near bottom, load more
            viewModel.fetchFromAPI { [weak self] in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
