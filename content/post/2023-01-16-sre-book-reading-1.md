---
layout:     post
title:      "读 <<97 Things Every SRE Should Know>> ---ing"
subtitle:  <<97 Things Every SRE Should Know>> 读书笔记 
date:       2023-01-16
author:     "Gemini"
URL: "/2023/1/16/sre-book-reading-1/"
image:      ""
categories: [ "Tech"]
tags:
- sre
- 英语
---

### 0x01
最近对SRE想做一些深入一下的了解,所以决定读一些相关英文原著。这本书是比较早出现读，对比来说，评价也很好，所以就从它开始吧   
整个书的结构是4部分，萌新,0-1，1-10，10-100 四个主要部分。但整本书其实是一个文章但集合，汇集了一群SRE对这个行业的一些思考和经验分享。    
分析下书本的地址：[<<97 Things Every SRE Should Know>>](https://hgwmfojk-my.sharepoint.com/:b:/g/personal/callmehecv_hgwmfojk_onmicrosoft_com/EW6LmsEMII9PphY3xX36TpoByGE3D6tMv_yg5qXZb7NdGg?e=rs8keK)  
### 0x02 萌新
1. #### Site Reliability Engineering in Six Words
`Virtually everything SREs do relies on our ability to do six things: measure, analyze, decide, act, reflect, and repeat.`    
作者用6个词来表述SRE的能力和工作内容，分别是:测量，分析，决策，行动，反思和重复。逻辑上其实是渐进和循环，同时又不断向前推进。
测量获取基础数据，然后对基础数据做分析，通过分析结果来做出决策。接着就是决策的执行，执行之后我们也需要反馈和反思，改进不好的点，然后带着改进进入下一个循环。    
所以从另一个方面也可以看出，收集测量数据是起点,SRE就是数据驱动的。    
2. #### Do We Know Why We Really Want Reliability?
作者讲述了他的困惑，那些以前因为不可靠受到批评的公司，如今却价值数百亿美元，他们有些甚至对网站对可靠性投入基本没有。针对上升期对公司，获得新客户或维持老客户的收益，看起来远远大于对网站可靠性的投入。因为就算在网站可靠性没那么好的情况下，客户那边也往往不愿意改变。   
上面是作者的真实想法，从我的角度来说，大多数公司往往是短视的。这很正常，新兴的公司，第一目标是活下去，而业务处于基本可以就行，这本来就是一个平衡。但SRE本来也是大公司搞出来的，为啥？因为他们不用担心随时死掉，又足够的时间和金钱在这方面进行长期投入，然后收到正向的回报。   
所以总结来说，不是公司不愿意，而是公司玩不起。
3. #### Building Self-Regulating Processes
todo:...