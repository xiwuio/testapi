import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'

const app = new Hono()

app.use(logger(), cors())

app.get('/', (c) => {
  return c.text('Hello Hono!')
})

app.post('/api/payment/callback', async (c) => {
  console.log('--------------------------------')
  // 打印所有请求头
  console.log('请求头 ->', c.req.header())
  // 打印所有请求体
  console.log('请求体 ->', await c.req.json())
  // 打印所有查询参数
  console.log('查询参数 ->', c.req.query())
  console.log('--------------------------------')
  return c.json({ success: true })
})

export default {
  port: 8000,
  fetch: app.fetch,
}
