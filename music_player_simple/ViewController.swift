//
//  ViewController.swift
//  music_player_simple
//
//  Created by 박훈성 on 2021/03/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
  
  
  //MARK: - Properties
  var player: AVAudioPlayer! //AudioPlayer
  var timer: Timer! //Timer
  var playPauseBtn: UIButton! //Play , Pause Button
  var timeLabel: UILabel! //Time Label
  var progressSlider: UISlider! //Play Slider

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.addView()
    self.initializePlayer()
    self.playPauseBtn.addTarget(self, action: #selector(onPlayPauseBtnClicked), for: .touchUpInside)
    self.progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
  }
  
  //MARK: - Custom Methods
  
  //뷰 만들기
  func addView() {
    self.addPlayPauseBtn()
    self.addLabel()
    self.addSlider()
  }
  
  //재생 , 일시정지 버튼 뷰 생성
  func addPlayPauseBtn() {
    let btn: UIButton = UIButton(type: .custom)
    btn.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(btn)
    
    btn.setImage(UIImage(named: "button_play"), for: .normal)
    btn.setImage(UIImage(named: "button_pause"), for: .selected)
    
    let centerX: NSLayoutConstraint
    centerX = btn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    
    let centerY: NSLayoutConstraint
    centerY = NSLayoutConstraint(item: btn, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.8, constant: 0)
    
    let width: NSLayoutConstraint
    width = NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .width, multiplier: 0.8, constant: 0)
    
    let height: NSLayoutConstraint
    height = btn.heightAnchor.constraint(equalTo: btn.widthAnchor)
    
    centerX.isActive = true
    centerY.isActive = true
    width.isActive = true
    height.isActive = true
    
    self.playPauseBtn = btn
  }
  
  //Time Label 뷰 생성
  func addLabel() {
    let label: UILabel = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    
    self.view.addSubview(label)
    
    label.text = "00:00:00"
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    
    let centerX: NSLayoutConstraint
    centerX = label.centerXAnchor.constraint(equalTo: self.playPauseBtn.centerXAnchor)
    
    let top: NSLayoutConstraint
    top = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: playPauseBtn, attribute: .bottom, multiplier: 1.1, constant: 0)
    
    centerX.isActive = true
    top.isActive = true
    
    self.timeLabel = label
  }
  
  
  // 슬라이더 뷰 생성
  func addSlider() {
    let slider: UISlider = UISlider()
    slider.translatesAutoresizingMaskIntoConstraints = false
    
    slider.minimumTrackTintColor = .orange
    
    self.view.addSubview(slider)
    
    let centerX: NSLayoutConstraint
    centerX = slider.centerXAnchor.constraint(equalTo: self.timeLabel.centerXAnchor)
    
    let top: NSLayoutConstraint
    top = NSLayoutConstraint(item: slider, attribute: .top, relatedBy: .equal, toItem: timeLabel, attribute: .bottom, multiplier: 1.05, constant: 0)
    
    let leading: NSLayoutConstraint
    leading = slider.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30)
    
    let trailing: NSLayoutConstraint
    trailing = slider.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -30)
    
    centerX.isActive = true
    top.isActive = true
    leading.isActive = true
    trailing.isActive = true
    
    self.progressSlider = slider
  }
  
  //초기화
  func initializePlayer() {
    
    //음원 에셋 파일 가져오기
    guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
      print("@Error1: 음원 파일을 불러올 수 없습니다.")
      return
    }
    
    //player 프로퍼티에 해당 음원 저장
    do {
      try self.player = AVAudioPlayer(data: soundAsset.data)
      self.player.delegate = self
    } catch let error as NSError {
      print("@Error2: 플레이어 초기화에 실패했습니다.")
      print("@Error2 Code: \(error.code), Message: \(error.localizedDescription)")
    }
    
    //slider value 설정
    self.progressSlider.maximumValue = Float(self.player.duration)
    self.progressSlider.minimumValue = 0
    self.progressSlider.value = Float(self.player.currentTime)
  }
  
  //timeLabel 업데이트
  func updateTimeLabelText(time: TimeInterval) {
    
    //타임인터벌을 분 , 초 , 밀리초 단위로 변환
    let minute: Int = Int(time / 60)
    let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
    let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
    
    //2자리 분 : 2자리 초 : 2자리 밀리초 포맷으로 String 구성
    let timeText: String = String(format: "%02d:%02d:%02d", minute,second,milisecond)
    
    //timeLabel에 해당 텍스트 적용
    self.timeLabel.text = timeText
  }
  
  //타이머 생성 및 실행
  func makeAndFireTimer() {
    
    //0.01초의 타임 인터벌을 걸어 0.01초마다 block 클로저가 호출되며 timeLabel 및 slider value 변경
    self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self] (timer: Timer) in
      
      if self.progressSlider.isTracking { return }
      
      self.updateTimeLabelText(time: self.player.currentTime)
      self.progressSlider.value = Float(self.player.currentTime)
    })
    
    //타이머 실행
    self.timer.fire()
  }
  
  //타이머 해제
  func invalidateTimer() {
    self.timer.invalidate()
    self.timer = nil
  }
  
  //재생 , 일시정지 버튼 클릭 시 동작
  @objc func onPlayPauseBtnClicked(_ sender: UIButton) {
    
    sender.isSelected = !sender.isSelected
    
    if sender.isSelected {
      self.player.play()
      self.makeAndFireTimer()
    } else {
      self.player.pause()
      self.invalidateTimer()
    }
    
    
  }
  
  //슬라이더 값 변경 시 동작
  @objc func sliderValueChanged(_ sender: UISlider) {
    
    self.player.pause()
    self.updateTimeLabelText(time: TimeInterval(sender.value))
    if sender.isTracking { return }
    self.player.currentTime = TimeInterval(sender.value)
    
    if self.playPauseBtn.isSelected {
      self.player.play()
    }
    
  }
  
  //MARK: - AVAudioPlayer Delegate
  
  //재생이 끝났을 때
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    self.invalidateTimer()
    self.playPauseBtn.isSelected = false
    self.progressSlider.value = 0
    self.updateTimeLabelText(time: 0)
    
  }
  
}

