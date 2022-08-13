---
title: Use the boring stuff
layout: post
date: 2022/08/13
description: Being intentional about our technology choices
tags: software-design architecture
author: Aumit Leon
permalink: use-the-boring-stuff
---

Software Engineering is a dynamic field filled with constant learning. The landscape of technologies is constantly shifting as people invent ever newer and ingenious ways of doing things. [How many API frameworks are there?](https://www.techempower.com/benchmarks/#section=data-r21) 

Software engineers think of themselves as creatives, many as innovators -- operating at the bleeding edge is a natural inclination. We look for ways to sharpen our tools and satiate our curiosities, and -- let's be honest -- keep ourselves relevant. We try to keep up with the latest hotness on hacker news, hoping to not be left behind. In this field, learning new tech is both fun, and existential.

But while it is fun and at times necessary to explore new technologies, resilient systems and growing products (*especially* products in their infancy) don't live on the bleeding edge. While true, the vast majority of engineers aren't building systems that need to be as resilient as rockets being fired into orbit -- an outage for most software just results in perturbed customers and a groggy engineer paged at an ungodly hour. For the most part, SaaS is not life or death. So, why should you use boring stuff?

As with all engineering decisions, tradeoffs must be considered. Consider what it is you are optimizing for. Are you hacking on a personal project while trying to get exposure into tech you don't use in your day-to-day? It's likely safe to try that new library. Working on a team that's building a software product that has real users, with real SLAs? You may want to reconsider. 

While there are certainly benefits to using new tech, it's important to balance your technical choices against your ultimate objective. Figure out what you are optimizing for and balance your choices accordingly. Some startups and green field teams think about using bleeding edge tech to attract talent interested in working on the newest technologies of the day -- this has short term benefits in terms of recruitment, but has long term drawbacks that pose existential threats to the underlying product. New technologies are by definition unexplored -- choosing new tech means you are sending your engineers into uncharted waters. A team that should be focused on executing product ends up debugging complicated issues that don't have readily available stack overflow answers. While you are mired in the intracies of deploying and debugging some framework at scale, your competitors may have chosen a more vanilla option that let them move much faster and focus on what really matters in the market: the product. 

Choosing boring tech means choosing the well worn path. The kinks have been ironed out, intricacies explored, and communities formed. Boring tech is well maintained with plenty of prior art. Unless you are in a unique position that merits untested tech, choose the boring option. Your users, team, and future self will be much obliged. 

The merits (or demerits) of technical choices don't reveal themselves until time has passed, systems have been pushed to scale, and Murphy's law has ensured that what *could* go wrong, *has*. Make your choice wisely, and do so with a clear vision of your objectives. 



 

