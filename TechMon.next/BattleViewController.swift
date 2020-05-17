//
//  BattleViewController.swift
//  Tech Mon
//
//  Created by 植田真梨 on 2020/05/15.
//  Copyright © 2020 Ueda Maririn. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!

    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPLabel: UILabel!
    @IBOutlet var enemyMPLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var player: Character!
    var enemy: Character!
   
    
    var gameTimer: Timer!
    var isPlayerAttackAvailable: Bool = true
    
    func updateUI() {
        //プレーヤーのステータスを反映
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        //敵のステータスを反映
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
        
    }
    var playerHP = 100
    var playerMP = 0
    var playerTP = 0
    var enemyHP = 200
    var enemyMP = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //ステータスの反映
        
        
         //キャラクターの読み込み
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        
        //プレイヤーのステータスを反映
        playerNameLabel.text = "勇者"
        playerImageView.image = UIImage(named: "yusya.png")
      /* playerHPLabel.text = "\(playerHP) / 100"
        playerMPLabel.text = "\(playerMP) / 20"*/
        //敵のステータスを反映
        enemyNameLabel.text = "ドラゴン"
        enemyImageView.image = UIImage(named: "monster.png")
    /*   enemyHPLabel.text = "\(enemyHP) / 400"
        enemyMPLabel.text = "\(enemyMP) / 35"*/

      
        //ゲームスタート
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
        
        gameTimer.fire()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
  
    //0.1秒ごとにゲームの状態を更新する
    @objc func updateGame() {
        
        //プレイヤーのステータスを更新
        playerMP += 1
        if playerMP >= 20 {
            
            isPlayerAttackAvailable = true
            playerMP = 20
        } else {
            
            isPlayerAttackAvailable = false
        }
        
        //敵のステータスを更新
        enemyMP += 1
        if enemyMP >= 35 {
            
             enemyAttack()
            enemyMP = 0
        }
        
        playerMPLabel.text = "\(playerMP) / 20"
        enemyMPLabel.text = "\(enemyMP) / 35"
    }
    
    //敵の攻撃
    func enemyAttack() {
        
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        playerHP -= 20
        
        playerHPLabel.text = "\(playerHP) / 100"
        
        if playerHP <= 0 {
            
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }
    }
    //勝敗判定をする
    func judgeBattle() {
        
        if player.currentHP <= 0 {
             finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        } else if enemy.currentHP <= 0 {
            
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
        
    }
    //勝利が決定した後の処理
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool) {
        
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        var finishMessage: String = ""
        if isPlayerWin {
            
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！！"
        } else {
            
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北…"
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
        @IBAction func attackAction(){
        
        if isPlayerAttackAvailable {
            
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
           enemy.currentHP -= player.attackPoint
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP {
                
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
            
            judgeBattle()
            }
            
            enemyHP -= 30
                       playerMP = 0
                
                       enemyHPLabel.text = "\(enemyHP) / 200"
                       playerMPLabel.text = "\(playerMP) / 20"
                
                       if enemyHP <= 0 {
                    
                       finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
           
    }
        @IBAction func fireAction() {
        
        if isPlayerAttackAvailable && player.currentTP >= 40 {
            
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            if player.currentTP <= 0 {
                
                player.currentTP = 0
            }
            player.currentMP = 0
            
            judgeBattle()
        }
    }
    
        @IBAction func tameruAction() {
            
        if isPlayerAttackAvailable {
            
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 20
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
        }
    }
}

