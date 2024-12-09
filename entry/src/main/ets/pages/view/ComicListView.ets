import { LogUtil } from '@pura/harmony-utils'
import { ComicResponse, comics, random, search } from '../../api/comic'
import { SortType } from '../../api/models'
import { SortItems } from '../../common/Config'
import { PreferenceItem } from '../../utils/Preference'
import ComicList, { ComicListAttribute } from '../component/ComicList'
import { BackType, TitleBar, TitleType } from '../component/TitleBar'
import { SymbolGlyphModifier } from '@kit.ArkUI'

@Builder
export function ComicListViewBuilder(name: string, param: Object) {
  ComicListView()
}

@Component
export default struct ComicListView {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @Consume('pageStack') pageStack: NavPathStack
  @State searchParam: ComicListOptions | undefined = undefined
  @State attr: ComicListAttribute | undefined = undefined
  @State @Watch('sortChange') sort: SortType = SortType.Newest
  @State @Watch('categoryChange') category: string[] = []
  @State showCategory: boolean = false

  aboutToAppear(): void {
    this.searchParam = this.pageStack.getParamByName('ComicListView')[0] as ComicListOptions
    this.buildAttr()
  }

  sortChange() {
    this.buildAttr()
  }

  categoryChange() {
    this.buildAttr()
  }

  buildAttr() {
    if (this.searchParam?.type === SearchType.Custom) {
      // 关键字查询
      this.attr = {
        type: 'remote',
        api: search,
        sort: this.sort,
        param1: this.searchParam.key,
        param2: this.category
      }
    } else if (this.searchParam?.type === SearchType.Category) {
      // 分类查询
      LogUtil.info('分类查询：', this.searchParam.key)
      this.attr = {
        type: 'remote',
        api: comics,
        sort: this.sort,
        param1: this.searchParam.key ? encodeURI(this.searchParam.key) : '',
      }
    } else {
      // 随机查询
      this.attr = {
        type: 'remote',
        api: (): Promise<ComicResponse> => {
          return new Promise<ComicResponse>((resolve, reject) => {
            random().then(res => {
              resolve({
                comics: {
                  docs: res.comic,
                  page: 1,
                  pages: 1,
                  total: res.comic.length,
                  limit: res.comic.length,
                }
              })
            }).catch((err: Error) => {
              reject(err)
            })
          })
        }
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          titleBarColor: Color.White,
          statusBarColor: Color.White,
          centerType: TitleType.TEXT,
          centerText: this.searchParam?.key,
          centerTextColor: $r('app.color.common_button_background_light'),
          leftBackType: BackType.NONE,
          leftBackFillColor: $r('app.color.common_button_background_light'),
          leftOnClick: () => {
            this.pageStack.pop()
          },
          rightType: TitleType.CUSTOM,
          rightCustomView: () => {
            this.rightBuilder()
          }
        })

        ComicList({ attr: this.attr, canSwipe: false })
      }
      .height('100%')
      .width('100%')
      .padding({
        bottom: this.bottomRectHeight,
        left: 10,
        right: 10
      })

      Flex()
        .width(0)
        .height(0)
        .borderRadius({ topRight: 30, bottomRight: 30 })
        .bindSheet(this.showCategory, this.categoryFilter(), {
          height: SheetSize.FIT_CONTENT,
          showClose: false,
          dragBar: false,
          blurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
          onDisappear: () => {
            this.showCategory = false
          },
        })
    }
    .mode(NavDestinationMode.STANDARD)
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    })
  }

  @Builder
  categoryFilter() {

  }

  @Builder
  sortMenu() {
    Menu() {
      ForEach(SortItems, ((item: PreferenceItem) => {
        MenuItem({
          symbolEndIcon: new SymbolGlyphModifier(item.icon as Resource)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor([$r('app.color.common_button_background_light')]),
          content: item.name,
        })
          .contentFont({ size: 16 })
          .selected(this.sort === item.value)
          .selectIcon(new SymbolGlyphModifier($r('sys.symbol.checkmark'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor([$r('app.color.common_button_background_light')])
          )
          .onChange(selected => {
            if (selected) {
              this.sort = SortType[item.key]
            }
          })
      }))

    }
  }

  /**
   * 右侧自定义视图
   */
  @Builder
  rightBuilder() {
    Row() {
      Image($r('app.media.ic_public_sort'))
        .height(20)
        .fillColor($r('app.color.common_button_background_light'))
        .margin({ right: 10 })
        .bindMenu(this.sortMenu)

      Image($r('app.media.ic_public_category'))
        .height(20)
        .fillColor($r('app.color.common_button_background_light'))
        .margin({ right: 10 })
        .visibility(this.searchParam?.type === SearchType.Custom ? Visibility.Visible : Visibility.None)

      Image($r('app.media.ic_public_search'))
        .height(20)
        .fillColor($r('app.color.common_button_background_light'))
        .onClick(() => {
          this.pageStack.pushPath({ name: 'ComicSearch' })
        })
    }
  }
}

export interface ComicListOptions {
  type: SearchType
  key?: string
}

export enum SearchType {
  Random,
  Category,
  Custom
}