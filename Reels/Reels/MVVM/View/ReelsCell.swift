// ReelsCell.swift
import UIKit
import AVFoundation

class ReelsCell: UITableViewCell {

    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var playerItem: AVPlayerItem?

    var onMuteTapped: (() -> Void)?
    var onLikeTapped: (() -> Void)?

    private let loader = UIActivityIndicatorView(style: .large)

    private let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.trackTintColor = .lightGray
        view.progressTintColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

     let muteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Unmute", for: .normal)
        button.backgroundColor = .black.withAlphaComponent(0.6)
        button.tintColor = .white
        button.layer.cornerRadius = 8
        return button
    }()

     let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Like", for: .normal)
        button.backgroundColor = .black.withAlphaComponent(0.6)
        button.tintColor = .white
        button.layer.cornerRadius = 8
        return button
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    
    private var timeObserver: Any?

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerItem = nil
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.clipsToBounds = true
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        loader.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        muteButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(loader)
        
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        contentView.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            progressView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])

        buttonStack.addArrangedSubview(likeButton)
        buttonStack.addArrangedSubview(muteButton)
        contentView.addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            buttonStack.heightAnchor.constraint(equalToConstant: 40),
            buttonStack.widthAnchor.constraint(equalToConstant: 200)
        ])

        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
    }

    @objc private func muteTapped() {
        onMuteTapped?()
    }

    @objc private func likeTapped() {
        onLikeTapped?()
    }

    func configure(with reel: Reel, isMuted: Bool) {
        layoutIfNeeded()
        guard let url = URL(string: reel.mediaURL), reel.isVideo else { return }
        loader.startAnimating()

        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = isMuted ? 0 : 1

        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else { return }
        playerLayer.frame = UIScreen.main.bounds//contentView.bounds
        playerLayer.videoGravity = .resizeAspect

        contentView.layer.insertSublayer(playerLayer, at: 0)
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restartVideo),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)

        loader.stopAnimating()
        muteButton.setTitle(isMuted ? "Unmute" : "Mute", for: .normal)
        likeButton.setTitle(reel.isLiked ? "Dislike" : "Like", for: .normal)

        loader.stopAnimating()
        updateProgress()
    }

    func play(isMuted: Bool) {
        player?.volume = isMuted ? 0 : 1
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    @objc private func restartVideo() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    private func updateProgress() {
        guard let player = player else { return }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
                                                      queue: .main) { [weak self] time in
            guard let duration = player.currentItem?.duration.seconds,
                  duration.isFinite, duration > 0 else { return }
            let currentTime = time.seconds
            self?.progressView.progress = Float(currentTime / duration)
        }
    }
}
