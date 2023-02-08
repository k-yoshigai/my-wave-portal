// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver; // wave を送ったユーザーのアドレス
        string message; // ユーザーが送ったメッセージ
        uint256 timestamp; // ユーザーが wave を送った瞬間のタイムスタンプ
    }

    Wave[] waves;

    mapping(address => uint256) public lastWaveAt;

    constructor() payable {
        console.log("We have been constructed");
        // 初期シードを設定
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        /* 現在のユーザーが wave を送信している時刻と前回 wave を送信した時刻が15分以上離れているか確認 */
        require(
            lastWaveAt[msg.sender] + 15 minutes < block.timestamp,
            "Wait 15m"
        );
        /* ユーザーの現在のタイムスタンプを更新*/
        lastWaveAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s waved w/ message %s", msg.sender, _message);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        // ユーザー用のシードを設定
        seed = (block.timestamp + block.difficulty) % 100;
        console.log("Random # generated %d", seed);

        // ユーザーが ETH を獲得する確率を50%に設定
        if (seed < 50) {
            console.log("%s won!", msg.sender);
            /* wave を送ってくれたユーザーに 0.0001 ETH を送る*/
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        } else {
            console.log("%s did not win", msg.sender);
        }

        /* コントラクト側で emit されたイベントに関する通知をフロントで取得できるようにする */
        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}
