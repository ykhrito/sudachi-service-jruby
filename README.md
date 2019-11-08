# sudachi-service-jruby

## What's this?

[Sudachi](https://github.com/WorksApplications/Sudachi) をデーモン化してみたかった。

JRuby + win32-service で Windows サービス化し、ただフリガナを返しているだけです。

## Install

JDK, JRuby はインストールされているものとします。
また Sudachi も適当な場所に展開されているものとし、以下 `C:\sudachi` とします。

sudachi-service.rb をクローンするなりダウンロードするなりして `C:\sudachi` にコピーします。

必要ならエディタで開いて設定ファイルパスやポート番号等を修正します。

win32-service の gem をインストール。

```
>gem install win32-service
```

管理者権限のコマンドプロンプトでサービスを作成。

```
>sc create SudachiService binPath= "C:\jruby-9.2.9.0\bin\jrubyw.exe -C C:\sudachi sudachi-service.rb"
```

サービス管理ツールを起動し、SudachiService が登録されているのを確認します。

必要に応じて自動起動にするなど設定を変更し、サービスを開始します。

正常に起動ができたら、Windows ファイアウォールで TCP ポートへの接続を適当に許可してください。

## Usage

TCP で設定したポートに接続して UTF-8 の文字列を送信すると UTF-8 の文字列が返却されます。

例えば irb で確認すると

```
irb(main):001:0> require 'socket'
true
irb(main):002:0> s = TCPSocket.open('localhost', 14343)
#<TCPSocket:fd 2180>
irb(main):003:0> s.puts '捕鯨'
nil
irb(main):004:0> s.flush
#<TCPSocket:fd 2180>
irb(main):005:0> puts s.gets
ホゲイ
nil
irb(main):006:0> s.close
nil
irb(main):007:0> exit
```

みたいな。

## License

MIT

## Copyright

Copyright &copy; 2019 Yukihiro ITO.
