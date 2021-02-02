//
//  ViewController.swift
//  Audio
//
//  Created by 이충현 on 2021/02/01.
//

import UIKit
// 오디오를 재생하려면 헤더파일인 AVFoundation이 필요하다
import AVFoundation

// 오디오를 재생하려면 AVAudioPlayerDelegate가 필요하기때문에 선언을 추가해준다
class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    var imgPlay: UIImage?
    var imgRecord: UIImage?
    var imgStop: UIImage?
    var imgPause: UIImage?
    
    
    var audioPlayer : AVAudioPlayer!
    // AVAudioPlater 인스턴스변수
    
    var audioFile : URL!
    // 재생할 오디오의 파일명 변수
    
    let MAX_VOLUME : Float = 10.0
    // 최대 볼륨, 실수형 상수
    
    var progressTimer : Timer!
    // 타이머를 위한 변수
    
    let timePlayerSelector = #selector(ViewController.updatePlayTime)
    // 재생타이머를 위한 상수
    
    let timeRecordSelector:Selector = #selector(ViewController.updateRecordTime)
    // 녹음 타이머를 위한 상수 추가
    
    
    @IBOutlet var pvProgressPlay: UIProgressView!
    @IBOutlet var lblCurrnetTime: UILabel!
    @IBOutlet var lblEndTime: UILabel!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPause: UIButton!
    @IBOutlet var btnStop: UIButton!
    @IBOutlet var slVolume: UISlider!
    
    @IBOutlet var btnRecord: UIButton!
    @IBOutlet var lblRecordTime: UILabel!
    
    @IBOutlet var imgView: UIImageView!
    //adudioRecorder라는 인스턴스 추가
    var audioRecorder : AVAudioRecorder!
    //현재 녹음모드 라는 것을 나타낼 isRecordMode 추가, 기본값은 false로 하여
    //처음 앱을 실행했을때 녹음모드가 아닌 재생모드가 나타나게 한다.
    var isRecordMod = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imgPlay = UIImage(named: "play.png")
        imgPause = UIImage(named: "pause.png")
        imgStop = UIImage(named: "stop.png")
        imgRecord = UIImage(named: "record.png")
        
        imgView.image = imgStop
        
        selectAudioFile()
        
        if !isRecordMod {
            // 녹음모드가 아니고 재생모드이기때문에 initPalay함수 호출
            initPlay()
            //조건에 해당하는 것이 재생모드이므로 Record버튼과 재생 시간은 비활성화
            btnRecord.isEnabled = false
            lblRecordTime.isEnabled = false
        } else {
            // 녹음모드이기 때문에 initRecord함수 호출
            initRecord()
        }
    }
    
    //녹음파일 생성하기
    func selectAudioFile() {
        if !isRecordMod {
            // 녹음모드가 아닐때  재생모드일때 오디오 파일인   Sicilian_Breeze.mp3가 선택됨
                
            // audioFile 변수를 추가해준 mp3로 설정
            audioFile = Bundle.main.url(forResource: "Sicilian_Breeze", withExtension: "mp3")
        } else {
            // 녹음모드일때
            // 새파일인 recordFile.m4a가 생성됨
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            audioFile = documentDirectory.appendingPathComponent("recordFile.m4a")
        }
    }
    
    //녹음을 위한 초기화 함수 (녹음과 관련하여 오디오의 포맷, 음질, 비트율, 채널 ㅁ치 샘플률을 초기화 하기위함)
    func initRecord() {
        // 포멧은 Apple Lossless, 음질은 최대, 비트율은 320,000bps(320kbps), 오디오 채널은 2로 하고 샘플률은 44100Hz로 설정
        let recordSettings = [
            AVFormatIDKey : NSNumber(value: kAudioFormatAppleLossless as UInt32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey : 44100.0] as [String : Any]
        
        
        // aduioFile을 URL로 하는 audioRecorder인스턴스를 생성
        do {
            audioRecorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
        } catch let error as NSError {
            print("Error-initRecord : \(error)")
        }
        
        //audioRecorder의 델리게이트를 self로 설정
        audioRecorder.delegate = self
        //볼륨 슬라이더 값을 1.0으로 설정
        slVolume.value = 1.0
        //audioPlayer의 볼륨도 슬라이더 값과 동일한 1.0으로 설정
        audioPlayer.volume = slVolume.value
        //총 재생시간을 0으로 바꿈
        lblEndTime.text = convertNSTimeInterval2String(0)
        //play, pause, stop 버튼을 비활성화로 설정
        setPlayButtons(false, pause: false, stop: false)
        
        
        let session = AVAudioSession.sharedInstance()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print("Error-setCategory: \(error)")
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("Error-setActive : \(error)")
        }
    }
    
    
    
    //오디오 재생을 위한 초기화함수
    //viewDidLoad 함수에 작성해도 되지만 나중에 재생모드, 녹음모드로 변경할때를 대비해 오디오 재생 초기화 과정과 녹음 초기화 과정을 분리해 놔야 편하다.
    func initPlay(){
        // do-try-catch -> 오류가 발생할 수 있는 함수를 호출할때 사용
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
        } catch let error as NSError {
            print("Error-initPlay : \(error)")
        }
        
        //슬라이더(slVolume)의 최대 볼륨을 상수 MAX_VOLUME인 10.0으로 초기화 한다
        slVolume.maximumValue = MAX_VOLUME
        //슬라이더(slVolume)의 볼륨을 1.0으로 초기화 한다
        slVolume.value = 1.0
        //프로그래스뷰(pvProgressPlay)의 진행을 0으로 초기화 한다.
        pvProgressPlay.progress = 0
        
        //audioPlayer 의 델리게이트를 self로 한다
        audioPlayer.delegate = self
        //prepareToPlay()를 실행한다
        audioPlayer.prepareToPlay()
        //audioPlayer의 볼륨을 방금 앞에서 초기화한 슬라이더(slVolume)의 볼륨 값 1.0으로 초기화한다
        audioPlayer.volume = slVolume.value
        
        //endTime 레이블인 lblEndTime에 총 재생 시간(오디오 곡 길이)을 나타내기 위해 lblEndTime을 초기화 할 것이다.
        // 이때 오디오의 총 재생 시간인 audioPlayer.duration을 직접 사용하기에는 시간 형태가 초단위 실수 값이므로 "00:00"형태로 바꾸는 함수가 필요하다
        lblEndTime.text = convertNSTimeInterval2String(audioPlayer.duration)
                            //오디오 파일의 재생 시간인 audioPlayer.duration 값을 convertNSTimeInterval2String 함수를 이용해 lblEndTime의 텍스트에 출력
        
        //lblCurrentTime의 텍스트에는 convertNSTimInterval2String 함수를 이용해 00:00가 출력되로록 0의 값을 입력
        lblCurrnetTime.text = convertNSTimeInterval2String(0)
        
        // play버튼은 오디오를 재생하는 역할을 하고 나머지는 오디오를 멈추게 한다.
        // 그러므로 재생에 관한 함수인 initPlay함수에 Play버튼을 활성화, 나머지 두 버튼은 비활성화 코드를 작성
        // btnPlay.isEnabled = true
        // btnPause.isEnabled = false
        // btnStop.isEnabled = false

        //위와 같이 코드를 작성해도 되지만 밑에서 만든 setPlayButtons함수를 사용하면 아래와 같이 위와 같은 의미이지만 간략한 소스가 된다.
        setPlayButtons(true, pause: false, stop: false)
    }
    
    // play, pause, stop 버튼의 동작여부를 설정하는 부분은 앞으로 계속 사용해야하므로 따로 함수를 만든다
    func setPlayButtons(_ play: Bool, pause: Bool, stop: Bool) {
        btnPlay.isEnabled = play
        btnPause.isEnabled = pause
        btnStop.isEnabled = stop
    }
    
    //"00:00"형태로 바꾸기 위해 TimeInterval 값을 받아 문자열(String)로 돌려보내주는 함수 생성
    func convertNSTimeInterval2String(_ time:TimeInterval) -> String {
        // 재생 시간의 매개변수인 time값을 60으로 나눈 '몫'을 정수 값으로 변환하여 상수 min값에 초기화 한다
        let min = Int(time/60)
        //time 값을 60으로 나눈 나머지 값을 정수 값으로 변환하여 상수 sec 값에 초기화
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        //이 두값을 활용해 "%02d:%02d"형태의 문자열 (String)로 변환하여 상수 strTime에 초기화
        let strTime = String(format: "%02d:%02d", min, sec)
        // 이 값을 호출한 함수로 돌려보낸다
        return strTime
    
    }
    
    @IBAction func btnPlayAudio(_ sender: UIButton) {
        //오디오 재생하기
        
        //audioPlayer.paly 함수를 실행해 오디오를 재생한다
        audioPlayer.play()
        //play 버튼은 비활성화, 나머지 버튼은 활성화
        setPlayButtons(false, pause: true, stop: true)
        
        imgView.image = imgPlay
        
        //프로그레스 타이머에 TimerscheduledTimer 함수를 사용하요 0.1초 간격으로 타이머를 생성하도록 구현
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timePlayerSelector, userInfo: nil, repeats: true)
        
    }
    
    @objc func updatePlayTime() {
        // 재생시간인 audioPlayer.currentTime을 레이블 lblCurrentTime에 나타낸다
        lblCurrnetTime.text = convertNSTimeInterval2String(audioPlayer.currentTime)
        // 프로그레스 뷰인 pvProgres Play의 진행상황에 audioPlayer.currentTime을 audioPlayer.duration으로 나눈 값을 표시
        pvProgressPlay.progress = Float(audioPlayer.currentTime/audioPlayer.duration)
    }
    
    @IBAction func btnPauseAudio(_ sender: UIButton) {
        //오디오 일시 정지하기
        
        audioPlayer.pause()
        setPlayButtons(true, pause: false, stop: true)
        imgView.image = imgPause
    }
    @IBAction func btnStopAudio(_ sender: UIButton) {
        //오디오 정지하기
        
        audioPlayer.stop()
        
        //정지했을 때 시간이 00:00이 되도록
        // 오디오를 정지하고 다시 재생하면 처음부터 재생해야 하므로 audioPlayer.currentTime을 0으로
        audioPlayer.currentTime = 0
        // 재생 시간도 00:00으로 초기화 하기 위해 convertNSTimeInterval2String(0) 이용
        lblCurrnetTime.text = convertNSTimeInterval2String(0)
        
        setPlayButtons(true, pause: false, stop: false)
        
        imgView.image = imgStop
        
        //타이머 무효화
        progressTimer.invalidate()
    }
    @IBAction func slChangeVolume(_ sender: UISlider) {
        //볼륨조절하기 슬라이더를 ㅊ터치해 좌우로 움직이면 볼륨이 조절되도록한다,
        audioPlayer.volume = slVolume.value
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //타이머를 무효화 한다
        progressTimer.invalidate()
        // play 버튼은 활성화 나머지버튼은 비활성화
        setPlayButtons(true, pause: false, stop: false)
    }
    
    
    @IBAction func swRecordMode(_ sender: UISwitch) {
        if sender.isOn {
            //스위치가 On이 되었을 때는 녹음 모드 이므로 오디오 재생을 중지하고, 현재 재생 시간을 00:00으로 만들고
            //isRecordMode의 값을 참(true)으로 설정하고, record 버튼과 녹음 시간을 활성화로 설정
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            lblRecordTime!.text = convertNSTimeInterval2String(0)
            isRecordMod = true
            btnRecord.isEnabled = true
            lblRecordTime.isEnabled = true
        } else {
            //스위치가 ON이 아닐때, 즉 재생모드일 때는 isRecordMode의 값을 거짓(false)로 설정하고
            //record 버튼과 녹음 시간을 비활성화 하면, 녹음시간은 0으로 초기화한다.
            isRecordMod = false
            btnRecord.isEnabled = false
            lblRecordTime.isEnabled = false
            lblRecordTime.text = convertNSTimeInterval2String(0)
        }
        //selectAudioFile 함수를 호출하여 오디오 파일을 선택하고, 모드에 따라 초기화 할 함수를 호출
        selectAudioFile()
        if !isRecordMod {
             initPlay()
        } else {
            initRecord()
        }
    }
    
    @IBAction func btnRecord(_ sender: UIButton) {
       
        if (sender as AnyObject).titleLabel?.text == "Record" {
            //만약에 버튼 이름이 Record이면 녹음을 하고 버튼 이름을 Stop으로 변경
            audioRecorder.record()
            (sender as AnyObject).setTitle("Stop", for: UIControl.State())
                // 녹음할 때 타이머가 작동하도록 progressTimer에 Time.scheduledTimer 함수를 호출하는데 0.1초 간격으로 타이머 생성
                progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeRecordSelector, userInfo: nil, repeats: true)
            imgView.image = imgRecord
        } else {
            //그렇지 않으면 현재 녹음 중이므로 녹음을 중단하고 버튼 이름을 Stop 으로 변경
            // 그리고 Play 버튼을 활성화하고 방금 녹음한 파일로 재생을 초기화한다
            audioRecorder.stop()
                // 녹음이 중지되면 타이머를 무효화
                progressTimer.invalidate()
            (sender as AnyObject).setTitle("Record", for: UIControl.State())
            btnPlay.isEnabled = true
            initPlay()
            imgView.image = imgStop
            
        }
    }
    
    // updateRecordTime 함수 생성, 타이머에 의해 0.1초 간격으로 이 함수를 실행하는데, 그 때마다 녹음시간이 표시됨
    @objc func updateRecordTime() {
        lblRecordTime.text = convertNSTimeInterval2String(audioRecorder.currentTime)
    }
    
    
}

