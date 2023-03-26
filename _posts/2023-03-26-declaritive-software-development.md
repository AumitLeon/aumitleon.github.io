---
title: LLMs and Declarative Software Development
layout: post
date: 2023/03/25
description: Leveraging LLMs and the naturalness of software to build software declaratively.
tags: machine-learning large-language-models nlp transformers software-engineering
author: Aumit Leon
permalink: llms-and-declaritive-software-development
---

Large language models (LLMs) and tools derived from them have taken the world by [storm](https://www.nytimes.com/2022/12/05/technology/chatgpt-ai-twitter.html). Southpark even dedicated an episode this season to ChatGPT, dubbed "*Deep Learning*". I have [previously written](https://aumitleon.dev/prompt-engineering-and-the-future-of-work) about the implications of LLMs and the wonders of prompt engineering; and just a few short weeks ago, OpenAI released the latest iteration of their GPT family of models: GPT-4. If you haven't, I'd highly recommend watching the [24 minute developer demo livestream](https://www.youtube.com/watch?v=outcGtbnMuQ). 

LLMs are getting more and more powerful, and the universe of possibilities around potential applications continues to expand.  One area that I've been keenly interested in is the application of LLMs to developer tools, and as the potential ultimate developer tool. LLMs are essentially token completion models, and excel in instances where a) it has tons of training data, and b) it's dealing with a problem space with a finite, *formal* grammar. It's not much of a surprise that GPT-4 was able to [score within the top 10% of human test takers on Bar exam](https://openai.com/research/gpt-4), as well as exceedingly well on a host of other limited tests. The reason GPT-4 is able to perform so well on standardized is because these are domains were there is lots of repetition, and the bounds of the domain are well defined. 

It would seem to follow then that GPT-4 and LLMs like it should be extremely powerful tools for people who write software. Software systems deal with a formal grammar, and there is a host of readily available training data for LLMs to train on -- this training data captures the common patterns that humans employ when writing software. In a paper titled [`On the Naturalness of Software`](https://dl.acm.org/doi/10.5555/2337223.2337322), it was posited that because code is written by humans, it exhibits statistically significant repitions in designs, patterns, and ultimately tokens. These repetitions are patterns that an LLM can learn, reproduce, and build on. Greg Brockman's live demo of GPT-4 writing a discord bot was just a small example of the power GPT-4 holds as an enabler of developer productivity. As software development becomes more declarative, we need to lean into our tools and learn how to use them in the most efficient ways. 

# Building a Chrome Extension With GPT-4
What better way to test GPT-4s abilities as a developer tool, than to use it to develop something? 

I had been looking to develop a simple Chrome extension powered by OpenAI APIs that could summarize text for me, but hadn't had the time to build it out on my own. I wanted to see just how powerful GPT-4 was as a tool for declarative software development. I knew what I wanted, and I knew generally how it should be built, but I didn't have the time to read the documentation to build it out -- could GPT-4 meet me in the middle and help me build what I had in mind? 

The answer is yes. 

This was a simple Chrome extension (a simple completions call to OpenAI APIs wrapped in a chrome extension), but it would be a solid test of GPT-4's ability to work with a software engineer to help them accomplish a technical goal faster than if they had to accomplish that goal on their own.

I gave GPT-4 a series of prompts, starting at the highest level, and then iteratively refining each individual component till it met my specifications. For this particular extension, I started with "*Write me a chrome extension that lets me summarize text using GPT 4*."

GPT-4 quickly responded with the high level file structure that would be required and then proceeded to provide code for all of the files. It was able to correctly ascertain the simple components of a chrome extension (`manifest.json`, a `html` file, and a `javsscript` file containing the logic of the extension). Almost all of the code was semantically and functionally correct, with the exception of a few small bugs. These bugs were easy for me to catch, as I knew what to look for, but they could potentially be a source of pain for someone blindly using GPT-4 to build things without knowledge of the thing they are asking GPT-4 to build. 

## Iteration

The particular bugs were fairly straightforward. GPT-4 had specified the `manifest.json` should be using `"manifest_version": 2`, but that's actually [deprecated](https://developer.chrome.com/docs/extensions/migrating/mv2-sunset/#:~:text=January%202024&text=Manifest%20V2%20enterprise%20policy%20expires,even%20ones%20installed%20using%20ExtensionInstallForcelist%20.). I manually flipped the 2 to a 3. 

The initial javascript code that GPT-4 produced was accurate, and did a good job of adding placeholders. You might note, I initially asked GPT-4 to build a summarizer *using GPT-4*, but it said that *there was no API call to GPT-4*, so instead, it would provide a placeholder to implement once it became available. This is factually incorrect, as of this writing, [GPT-4 is released for public beta](https://openai.com/waitlist/gpt-4-api) and you can query it via the `/completions` endpoint today if you specify it as the `model` in the JSON payload. Still, this is a forgivable bug -- a placeholder stub is still useful, even though its explanation was incorrect.

I asked GPT-4 to iterate and implement the placeholder function to actually lay out the logic of the API call it would need to make, and this is where I needed to cycle through a couple more iterations to get GPT-4 to accomplish what I envisioned. The code it produced to make the API call to OpenAI was functionally correct, except for 1 bug: it specified a non-existent endpoint. The code GPT-4 produced was attempting to make the API call to `https://api.openai.com/v1/engines/davinci-codex/completions`, where the real completions endpoint is `https://api.openai.com/v1/completions`. This might have been a [hallucination](https://en.wikipedia.org/wiki/Hallucination_(artificial_intelligence)) on GPT-4's part, but either way, a simple bug to fix if you know what to look for and manually verify the output.   What was interesting to note, however, was that even though the endpoint it specified was wrong, the rest of the structure of the request was correct -- it knew it should be a `POST` request, and knew the exact parameters to pass, and even filled them in with some sensible defaults. Below is the block produced by GPT-4:

```javascript
const response = await fetch(
  "https://api.openai.com/v1/engines/davinci-codex/completions",
  {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      prompt: prompt,
      max_tokens: 50, // Adjust the number of tokens as needed
      n: 1,
      stop: null,
      temperature: 0.5,
    })
  }
);
```

Other than the endpoint being wrong, I didn't like that the code  GPT-4 produced to make the API call was using `axios`. [`axios`](https://axios-http.com/docs/intro) is a third party library, and including it in a chrome extension would [require some additional bundling logic](https://stackoverflow.com/a/65315479), which would only add complexity that had no real benefit: I didn't need the flexibility of `axios`, I just needed to make a simple API call. For the next iteration, I asked GPT-4 to refactor the the API call function to use the standard [`fetch`](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch) API instead of `axios` to circumvent the need to add bundling logic. The code it produced was functionally correct, and I had to make no modifications.

At this point I basically had a working extension. I went through a couple more iterations asking GPT-4 to style the HTML for the extension popup, and also include a way to securely store the user's API key to make these API calls. GPT-4 completed the former with no issue (I didn't need this extension to be the Mona Lisa), but I needed to work through a couple of iterations for it to complete the latter. To support storing the API key, I asked it to allow the user to provide their key through the popup HTML, and then have the javascript store it securely. This is where my ignorance of browser APIs came in, as I didn't really know what the best practice was for chrome extensions working with API keys. GPT-4 produced code to store the API key in `chrome.storage.sync`, which is [chrome storage that syncs across your connected browsers](https://developer.chrome.com/docs/extensions/reference/storage/) (i.e., if you're signed into your Google account on multiple devices and use Chrome on those devices) -- this is in contrast to `chrome.storage.local`, which is simply local storage. The blow is the javascript code GPT-4 produced to accept the API key and copy-pasted text to summarize:

```javascript
document.getElementById("summarizeButton").addEventListener("click", async () => {
  const apiKey = document.getElementById("apiKey").value;
  const inputText = document.getElementById("inputText").value;
  const resultDiv = document.getElementById("result");

  if (!apiKey) {
      resultDiv.innerHTML = "Please enter your API key.";
      return;
  }

  if (inputText) {
      resultDiv.innerHTML = "Summarizing...";
      // Save the API key to Chrome storage
      chrome.storage.sync.set({ apiKey }, () => {
          console.log("API key saved");
      });

      const summary = await getSummary(apiKey, inputText);
      resultDiv.innerHTML = summary;
  } else {
      resultDiv.innerHTML = "Please paste your text in the textarea.";
  }
});
```

I loaded the extension into Chrome, and it was all working as expected. I now had a functionally working Chrome extension to summarize text for me, in about 30 minutes! If you'd like to use the extension yourself, check out the [GitHub repo](https://github.com/AumitLeon/too-long-didnt-read) README (which was also, in large part, produced by GPT-4). 

# Retrospective
This is undeniably a delightful way to build software. I went into this with a vision, some knowledge of what the final product should look like at a technical level, and had GPT-4 do the majority of the heavy lifting to produce the actual code. 

While GPT-4 isn't tuned for code completions in the way [codex](https://openai.com/blog/openai-codex) is, it still impressed me with its capabilities. The model adhered to my instructions, and for the most part it was able to build the iterations that I asked for. 

While very effective, I did have to correct some bugs and prompt it for iterations on improving aspects of the code that didn't meet my expectations, which only stresses the importance of ***verifying the code any LLM model produces for you***. GPT-4 responds with confidence even when it hallucinates, so it's important for users to take what it produces with a grain of salt. GPT-4 and LLMs are tools that augment and accelerate human expertise, not tools to replace humans. 

# What comes next?
In computing, abstraction is the trend line in the plot of progress across decades. As time has gone on, developer tools have introduced new abstractions meant to make the production of software more efficient, more ubiquitous, and more *human friendly*. We've gone from circuits, to punch cards, to assembly, to C, to languages built on top of other languages for the express purpose of adding syntactic sugar and protecting human coders from the vagaries of manual memory management and [null pointers](https://www.youtube.com/watch?v=HSmKiws-4NU). 

The trend is clear in the day's leading tools: the popularity of python is rooted in its simplicity -- it's why python sees increased adoption in courses taught at Undergraduate Computer Science departments around the world. The most popular version of python (`CPython`), is built in C. You might say python is just an abstraction over C, and in the ways that matter, you'd be right. 

These ideas extend beyond programming. The arc of progress in human-computer interaction is one that trends towards declarative tooling. The most powerful tooling is the kind where you tell it what you want (e.g., specify an end state), and the tools get to that state. The contrast to this is imperative tooling, where you control the building blocks that achieve that end state. In the field of software, declarative tooling is well understood and pervasive. SQL, in its infinite wisdom, is a declarative interface -- when you make a SQL query, you don't care about how the relational database engine achieves the result, you only care about the result. It is entirely up to the database engine's query optimization to produce that result in the most efficient way possible. As the software we build becomes more and more complex, the tools we use to build that software has become more and more declarative. 

Take [Kubernetes](https://kubernetes.io/) for example -- in its own documentation it states:
> Kubernetes is a portable, extensible, open source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation.

Kubernetes enables developers to build distributed applications and systems in a way that was infinitely more difficult in decades prior. Kubernetes' declarative philosophy exemplifies the modern trend towards declarative tooling, and away from imperative tooling. Even the most popular and widely used infrastructure management tools are all rooted in marketing themselves as declarative tools -- [Terraform](https://www.terraform.io/) makes clear that you just need to "describe an intended goal rather than the steps to reach that goal." All of this is with good reason -- imperative tooling gives you more flexibility, but puts more burden on the users and produces more bugs. Declarative tooling makes the things that should be easy, easy. 

With all of this being said, it's clear that GPT-4 and the LLMs around it are an evolution in declarative tooling. There was a sort of Bret Victor-esque shock when Greg Brockman had GPT-4 produce working code for a wireframe he drew in his notebook, and with good reason. These tools are incredibly powerful, and their inherently declarative nature will allow us to build bigger and better things. 

As always, it's important to remember that these are tools, and any sufficiently powerful tool needs to be used with caution. As I've laid out in my small experiment of building a Chrome extension, GPT-4 is plenty capable, but it still requires a steady hand. These tools are not at the level of L4 or L5 autonomous vehicles -- you still need an alert and engaged driver at the wheel. But, if you remain curious and use these tools as accelerators for your own learning and building, I think we're going to achieve some great things in the near and future. 
