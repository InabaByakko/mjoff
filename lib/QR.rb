require "barby"
require "barby/barcode/qr_code"
require "barby/outputter/ascii_outputter"
require "barby/outputter/png_outputter"
require "rqrcode"

class QR

  def initialize(data)
    @data = data.to_s
  end

  # PNG形式でデータURIスキームを生成
  def to_png_image
    'data:image/png;base64, ' + Base64.encode64(Barby::PngOutputter.new(barcode(@data)).to_png)
  end

  private
  def barcode(data)
    Barby::QrCode.new(data.encode("UTF-8"))
  end
end
