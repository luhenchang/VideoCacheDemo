//图片缓存工具
import fs from '@ohos.file.fs';

export class VideoCacheUtil {
  static readonly separator: string = '/'

  /**
   * 检测是否文件夹存在，不存在创建
   * @param dir
   */
  private static checkDirExist(dir: string): boolean {
    let exist = fs.accessSync(dir)
    return exist
  }

  /**
   * 清除一半的缓存
   * @param dir
   */
  static async clearVideoCache(dir: string): Promise<void> {
    if (!VideoCacheUtil.checkDirExist(dir)) {
      return
    }
    let files = fs.listFileSync(dir)
    files.forEach((deletePath, index) => {
      fs.unlinkSync(dir + VideoCacheUtil.separator + deletePath)
    })
  }
}
