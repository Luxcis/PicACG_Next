import axios, { AxiosResponse } from '@ohos/axios'
import { MD5, RandomUtil } from '@pura/harmony-utils'
import { HttpUtil } from '../utils/Http'
import { PicaPage } from '../common/Model'
import { Category, ComicDetailInfo, ComicEp, ComicSimpleInfo, SortType } from './models'
import { CommentResponse } from './profile'

export interface CollectionResponse {
  collections: Collection[]
}

export interface Collection {
  title: string
  comics: ComicSimpleInfo[]
}

export interface RecommendResponse {
  comics: ComicSimpleInfo[]
}

export interface DetailResponse {
  comic: ComicDetailInfo
}

export interface Recommend {
  id: string
  pic: string
  title: string
}

export interface CategoryResponse {
  categories: Category[]
}

export interface ComicResponse {
  comics: PicaPage<ComicSimpleInfo>
}

export interface RandomResponse {
  comic: ComicSimpleInfo[]
}

export interface KeywordResponse {
  keywords: string[]
}

/**另一个推荐接口: 其他人还在看(不需要认证)*/
export const otherRecommend = (_id?: string) => {
  if (!_id) {
    _id = MD5.digestSync(RandomUtil.getRandomNumber(Number.MIN_VALUE, Number.MAX_VALUE).toString()).substring(0, 24)
  }
  return new Promise<Recommend[]>((resolve, reject) => {
    axios.get('https://recommend.go2778.com/pic/recommend/get/?c=' + _id)
      .then((res: AxiosResponse<Recommend[]>) => {
        resolve(res.data)
      })
      .catch((err: Error) => {
        reject(err)
      })
  })
}

/**本子妹推荐*/
export const collections = (): Promise<CollectionResponse> => {
  return HttpUtil.get('/collections')
}

/**相关推荐*/
export const recommend = (_id: string): Promise<RecommendResponse> => {
  return HttpUtil.get(`/comics/${_id}/recommendation`)
}

/**漫画详细信息*/
export const detail = (_id: string): Promise<ComicDetailInfo> => {
  return HttpUtil.get(`/comics/${_id}`)
}

/**漫画目录*/
export const eps = (_id: string, page: number = 1): Promise<PicaPage<ComicEp>> => {
  return HttpUtil.get(`/comics/${_id}/eps`, { page })
}

/**分类*/
export const categories = (): Promise<CategoryResponse> => {
  return HttpUtil.get('categories')
}

/**漫画分页列表*/
export const comics = (page: number = 1, s: SortType = SortType.Newest, c?: string): Promise<ComicResponse> => {
  return HttpUtil.get('/comics', { page, c, s })
}

/**关键字查询分页列表*/
export const search = (page: number = 1, s: SortType = SortType.Newest, keyword?: string, categories?: string[]):
  Promise<ComicResponse> => {
  return HttpUtil.request('POST', '/advanced-search', {
    params: { page, s },
    data: {
      categories,
      keyword,
      sort: s
    }
  })
}

/**随机本子*/
export const random = (): Promise<RandomResponse> => {
  return HttpUtil.get('/comic/random')
}

/**大家都在搜*/
export const keywords = (): Promise<KeywordResponse> => {
  return HttpUtil.get('/keywords')
}

/**漫画评论*/
export const comments = (comicId: string, page: number = 1): Promise<CommentResponse> => {
  return HttpUtil.get(`/comics/${comicId}/comments`, { page })
}

